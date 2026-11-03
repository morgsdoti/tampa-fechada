// Tampa Fechada — abrir o app deixa o Mac funcionando com a tampa fechada
// (pmset disablesleep 1); fechar o app volta ao normal (disablesleep 0).
// Se tirar o carregador com ele aberto, avisa (pra não ir pra mochila ligado).

import Cocoa
import IOKit.ps

func sleepDisabled() -> Bool {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
    p.arguments = ["-g"]
    let pipe = Pipe()
    p.standardOutput = pipe
    guard (try? p.run()) != nil else { return false }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    p.waitUntilExit()
    let out = String(data: data, encoding: .utf8) ?? ""
    return out.split(separator: "\n").contains {
        $0.contains("SleepDisabled") && $0.trimmingCharacters(in: .whitespaces).hasSuffix("1")
    }
}

// Pede a senha pela janela nativa do macOS.
func setSleepDisabled(_ on: Bool) -> Bool {
    let prompt = on
        ? "Tampa Fechada quer deixar o Mac funcionando com a tampa fechada."
        : "Tampa Fechada quer voltar o Mac ao normal (dormir com a tampa fechada)."
    let src = "do shell script \"/usr/bin/pmset -a disablesleep \(on ? 1 : 0)\" with prompt \"\(prompt)\" with administrator privileges"
    var err: NSDictionary?
    NSAppleScript(source: src)?.executeAndReturnError(&err)
    return err == nil && sleepDisabled() == on
}

func onBattery() -> Bool {
    let blob = IOPSCopyPowerSourcesInfo().takeRetainedValue()
    guard let type = IOPSGetProvidingPowerSourceType(blob)?.takeUnretainedValue() else { return false }
    return (type as String) == kIOPSBatteryPowerValue
}

func showAlert(_ title: String, _ text: String) {
    NSApp.activate(ignoringOtherApps: true)
    let a = NSAlert()
    a.messageText = title
    a.informativeText = text
    a.runModal()
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var window: NSWindow!
    var wasOnBattery = false
    var timer: Timer?
    var allowQuit = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMenu()
        if !sleepDisabled() && !setSleepDisabled(true) {
            showAlert("Não ativei", "Sem a senha o Mac não deixa mudar essa configuração. Abra o app de novo quando quiser.")
            allowQuit = true
            NSApp.terminate(nil)
            return
        }
        buildWindow()
        wasOnBattery = onBattery()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.checkPower()
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    func checkPower() {
        let battery = onBattery()
        defer { wasOnBattery = battery }
        guard battery && !wasOnBattery else { return }
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert()
        a.messageText = "Você tirou o carregador"
        a.informativeText = "O Mac continua configurado pra não dormir com a tampa fechada. Se for guardar na mochila, desligue antes — senão ele esquenta lá dentro."
        a.addButton(withTitle: "Desligar e fechar")
        a.addButton(withTitle: "Manter ligado")
        if a.runModal() == .alertFirstButtonReturn {
            NSApp.terminate(nil)
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if allowQuit || !sleepDisabled() { return .terminateNow }
        if setSleepDisabled(false) { return .terminateNow }
        showAlert("Continua ligado", "Não consegui desligar (a senha foi cancelada). O app vai continuar aberto pra você tentar de novo.")
        return .terminateCancel
    }

    // Fechar a janela = fechar o app (e desligar o modo).
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApp.terminate(nil)
        return false
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }

    func buildMenu() {
        let main = NSMenu()
        let appItem = NSMenuItem()
        main.addItem(appItem)
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Desligar e fechar", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenu.addItem(withTitle: "Fechar janela", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        appItem.submenu = appMenu
        NSApp.mainMenu = main
    }

    func buildWindow() {
        let icon = NSImageView(image: NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: nil)!)
        icon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 52, weight: .regular)
        icon.contentTintColor = .systemOrange

        let title = NSTextField(labelWithString: "Ligado")
        title.font = .boldSystemFont(ofSize: 22)

        let body = NSTextField(wrappingLabelWithString: "Pode abaixar a tela: o Mac continua funcionando.\n\nPra voltar ao normal, é só fechar este app.")
        body.alignment = .center
        body.preferredMaxLayoutWidth = 280

        let button = NSButton(title: "Desligar e fechar", target: self, action: #selector(quit))
        button.bezelStyle = .rounded
        button.controlSize = .large

        let stack = NSStackView(views: [icon, title, body, button])
        stack.orientation = .vertical
        stack.spacing = 14
        stack.edgeInsets = NSEdgeInsets(top: 28, left: 32, bottom: 28, right: 32)
        stack.setCustomSpacing(22, after: body)

        window = NSWindow(contentRect: .zero, styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "Tampa Fechada"
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.contentView = stack
        window.setContentSize(stack.fittingSize)
        window.center()
        window.makeKeyAndOrderFront(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
