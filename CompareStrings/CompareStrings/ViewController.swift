import UIKit

class ViewController: UIViewController {

    private let string1Field = UITextField()
    private let string2Field = UITextField()
    private let resultLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let label1 = UILabel()
        label1.text = "String 1:"
        let label2 = UILabel()
        label2.text = "String 2:"

        for field in [string1Field, string2Field] {
            field.borderStyle = .roundedRect
            field.autocorrectionType = .no
            field.autocapitalizationType = .none
            field.returnKeyType = .done
            // Zdarzenie "Did End on Exit"
            field.addTarget(self, action: #selector(resignKeyboard(_:)), for: .editingDidEndOnExit)
        }
        string1Field.placeholder = "Wpisz pierwszy tekst"
        string2Field.placeholder = "Wpisz drugi tekst"

        let compareButton = UIButton(type: .system)
        compareButton.setTitle("Porównaj", for: .normal)
        compareButton.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        compareButton.addTarget(self, action: #selector(compareTapped(_:)), for: .touchUpInside)

        resultLabel.text = ""
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [label1, string1Field, label2, string2Field,
                                                   compareButton, resultLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @IBAction func compareTapped(_ sender: UIButton) {
        let s1 = string1Field.text ?? ""
        let s2 = string2Field.text ?? ""
        resultLabel.text = (s1 == s2) ? "Stringi są takie same" : "Stringi są różne"
    }

    @IBAction func resignKeyboard(_ sender: UITextField!) {
        sender.resignFirstResponder()
    }
}
