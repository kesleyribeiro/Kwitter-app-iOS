//
//  EditarVC.swift
//  Kwitter
//
//  Created by Kesley Ribeiro on 24/Mar/17.
//  Copyright © 2017 AppaoCubo. All rights reserved.
//

import UIKit

class EditarVC: UIViewController, UITextFieldDelegate {
    
    // Objetos da view
    @IBOutlet weak var nomeUsuarioTxtField: UITextField!
    @IBOutlet weak var nomeTxtField: UITextField!
    @IBOutlet weak var sobrenomeTxtField: UITextField!
    @IBOutlet weak var nomeCompletoLbl: UILabel!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var imagemPerfil: UIImageView!
    @IBOutlet weak var btnSalvar: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Atribuir para as constantes o nome de usuário e o nome completo do atual usuário
        let nomeUsuario = usuario!["nomeUsuario"] as? String
        let nomeCompleto = usuario!["nomeCompleto"] as? String
        
        // Incluir 'Nome e sobrenome' como array de elementos separados
        let arrayNomeCompleto = nomeCompleto!.characters.split {$0 == " "}.map(String.init)
        let nome = arrayNomeCompleto[0]
        let sobrenome = arrayNomeCompleto[1]
        
        let email = usuario!["email"] as? String
        let imagem = usuario!["imagem"] as? String
        
        // Definir o título da view
        navigationItem.title = "PERFIL"
        
        // Atribuir as informações aos objetos da view
        nomeUsuarioTxtField.text = nomeUsuario
        nomeTxtField.text = nome
        sobrenomeTxtField.text = sobrenome
        emailTxtField.text = email
        nomeCompletoLbl.text = "\(nomeTxtField.text!) \(sobrenomeTxtField.text!)"
        
        // Obter a imagem de perfil do usuário, se imagem estiver vazia
        if imagem != "" {
            
            // url path para a imagem
            let urlImagem = URL(string: imagem!)!
            
            // Obter a fila principal para executar este bloco
            DispatchQueue.main.async(execute: {
                
                // Obter o dadoImagem a partir da url da imagem
                let dadoImagem = try? Data(contentsOf: urlImagem)
                
                // Se dadoImagem não for nill, atribuir para imagemPerfil.image
                if dadoImagem != nil {

                    DispatchQueue.main.async(execute: {
                        self.imagemPerfil.image = UIImage(data: dadoImagem!)
                    })
                }
            })
        }

        // Arredondar bordas
        imagemPerfil.layer.cornerRadius = imagemPerfil.bounds.width / 2
        imagemPerfil.clipsToBounds = true
        btnSalvar.layer.cornerRadius = btnSalvar.bounds.width / 4.5

        // Cor
        btnSalvar.backgroundColor = corAzul
        btnSalvar.setTitleColor(.white, for: .normal)

        // Desabilitar botão inicialmente
        btnSalvar.isEnabled = false
        btnSalvar.alpha = 0.3

        // Delegando os textFields
        nomeUsuarioTxtField.delegate = self
        nomeTxtField.delegate = self
        sobrenomeTxtField.delegate = self
        emailTxtField.delegate = self

        // Adicionar target para a execução da função no textfield
        nomeTxtField.addTarget(self, action: #selector(EditarVC.textFieldDidChange(_:)), for: .editingChanged)
        sobrenomeTxtField.addTarget(self, action: #selector(EditarVC.textFieldDidChange(_:)), for: .editingChanged)
        nomeUsuarioTxtField.addTarget(self, action: #selector(EditarVC.textFieldDidChange(_:)), for: .editingChanged)
        emailTxtField.addTarget(self, action: #selector(EditarVC.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // Se tiver alguma informação alterada nos textfields
    func textFieldDidChange(_ textField : UITextView) {
        
        nomeCompletoLbl.text = "\(nomeTxtField.text!) \(sobrenomeTxtField.text!)"
        
        // Se textfields estão vazios - desabilitar botão Salvar
        if nomeUsuarioTxtField.text!.isEmpty || nomeTxtField.text!.isEmpty || sobrenomeTxtField.text!.isEmpty || emailTxtField.text!.isEmpty {

            btnSalvar.isEnabled = false
            btnSalvar.alpha = 0.3
            
        } // Habilitar botão Salvar se tiver mudança em alguma informação
        else {
            
            btnSalvar.isEnabled = true
            btnSalvar.alpha = 1
        }
    }

    // Botão Salvar
    @IBAction func salvarAlteracoes(_ sender: Any) {

        // Atribuir para as constantes os valores informados pelo usuário
        let nomeUsuario = nomeUsuarioTxtField.text!.lowercased()
        let nome = nomeTxtField.text!
        let sobrenome = sobrenomeTxtField.text!
        let nomeCompleto = nomeCompletoLbl.text!
        let email = emailTxtField.text!.lowercased()
        let id = usuario!["id"]!
        
        // Se não tiver preenchidos os dados
        if nomeUsuario.isEmpty || nome.isEmpty || sobrenome.isEmpty || email.isEmpty {

            // Placeholders ficam com textos em vermelho
            nomeUsuarioTxtField.attributedPlaceholder = NSAttributedString(string: "NOME DE USUÁRIO", attributes: [NSForegroundColorAttributeName: corAlteradaVermelho])
            nomeTxtField.attributedPlaceholder = NSAttributedString(string: "Nome", attributes: [NSForegroundColorAttributeName: corAlteradaVermelho])
            sobrenomeTxtField.attributedPlaceholder = NSAttributedString(string: "Sobrenome", attributes: [NSForegroundColorAttributeName: corAlteradaVermelho])
            emailTxtField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: corAlteradaVermelho])
        }
        // Se os dados foram preenchidos - salvar e atualizar informações
        else {
            
            // Remover teclado
            self.view.endEditing(true)
            
            // URL para o arquivo PHP
            let url = URL(string: "http://localhost/Kwitter/atualizarUsuario.php")!
            
            // Requisição para este arquivo
            var requisicao = URLRequest(url: url)
            
            // Método para passar os dados para este arquivo via POST
            requisicao.httpMethod = "POST"
            
            // Adicionar na requisição os campos que serão enviados
            let body = "nomeUsuario=\(nomeUsuario)&nomeCompleto=\(nomeCompleto)&email=\(email)&id=\(id)"
            
            // Suporte para todos os idiomas
            requisicao.httpBody = body.data(using: .utf8)
            
            // Processar o envio da requisição
            URLSession.shared.dataTask(with: requisicao) { data, response, error in

                // Obter a fila principal para executar este bloco
                DispatchQueue.main.async(execute: {

                    // Se não tiver erro
                    if error == nil {
                        do {
                            
                            // Obter o resultado JSON
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                            
                            // Enviar o objeto JSON para guardar em uma constante
                            guard let parseJSON = json else {
                                print("\nOcorreu um erro ao tentar o parse JSON: \(error)")
                                return
                            }
                            
                            // Obter id a partir do dicionário parseJSON
                            let id = parseJSON["id"]
                            
                            // Atualizar com sucesso
                            if id != nil {

                                // Salvar informações do usuário
                                UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                                usuario = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                                
                                // Ir para tabbar / view Home
                                DispatchQueue.main.async(execute: {
                                    appDelegate.entrar()
                                })
                            }

                        } // Error ao fazer json
                        catch {
                            // Obter a fila principal para executar este bloco
                            DispatchQueue.main.async(execute: {
                                let mensagem = "\(error)"
                                appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                            })
                            return
                        }
                        
                    } // Error na requisição
                    else {
                            // Obter a fila principal para executar este bloco
                            DispatchQueue.main.async(execute: {
                            let mensagem = error!.localizedDescription
                            appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                        })
                        return
                    }
                })
            } .resume()
        }
    }
}
