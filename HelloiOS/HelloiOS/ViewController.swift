import UIKit

class ViewController: UIViewController {

    private let helloLabel = UILabel()
    private let worldButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Label (zadanie 4)
        helloLabel.text = ""
        helloLabel.font = .preferredFont(forTextStyle: .title1)
        helloLabel.textAlignment = .center

        // Przycisk z nazwą "World" (zadanie 4)
        worldButton.setTitle("World", for: .normal)
        worldButton.titleLabel?.font = .preferredFont(forTextStyle: .title2)
        worldButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [helloLabel, worldButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        // Zadanie 2
        print("Hello iOS")

        // Zadanie 4: "Hello" + nazwa przycisku
        let buttonName = sender.titleLabel?.text ?? ""
        helloLabel.text = "Hello" + " " + buttonName

        // Zadanie 3: alert
        let alert = UIAlertController(title: "Hello World",
                                      message: "Witaj na kursie Technologie Mobilne",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
