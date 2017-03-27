//
//  RegistrarVC.swift
//  Kwitter
//
//  Created by Kesley Ribeiro on 12/Mar/17.
//  Copyright © 2017 AppaoCubo. All rights reserved.
//

import UIKit

class RegistrarVC: UIViewController {

    // Objetos da view
    @IBOutlet weak var nomeUsuarioTxt: UITextField!
    @IBOutlet weak var senhaTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var nomeTxt: UITextField!
    @IBOutlet weak var sobrenomeTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Botão Registrar
    @IBAction func registrarButton(_ sender: AnyObject) {
        
        // Atribuir para as constantes os valores informados pelo usuário
        let nomeUsuario = nomeUsuarioTxt.text!.lowercased()
        let senha = senhaTxt.text!
        let email = emailTxt.text!
        let nome = nomeTxt.text!
        let sobrenome = sobrenomeTxt.text!

        // Se não tiver preenchido os dados
        if nomeUsuario.isEmpty || senha.isEmpty || email.isEmpty || nome.isEmpty || sobrenome.isEmpty {
            
            // Placeholders ficam com textos em vermelho
            nomeUsuarioTxt.attributedPlaceholder = NSAttributedString(string: "Nome de usuário", attributes: [NSForegroundColorAttributeName: UIColor.red])
            senhaTxt.attributedPlaceholder = NSAttributedString(string: "Senha", attributes: [NSForegroundColorAttributeName: UIColor.red])
            emailTxt.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.red])
            nomeTxt.attributedPlaceholder = NSAttributedString(string: "Nome", attributes: [NSForegroundColorAttributeName: UIColor.red])
            sobrenomeTxt.attributedPlaceholder = NSAttributedString(string: "Sobrenome", attributes: [NSForegroundColorAttributeName: UIColor.red])
        }
        // Se os dados foram preenchidos - criar um novo usuário no MySQL
        else {
            
            // Remover o teclado
            self.view.endEditing(false)
            
            // URL para o arquivo PHP
            let url = URL(string: "http://localhost/Kwitter/registrar.php")!
            
            // Requisição para este arquivo
            var requisicao = URLRequest(url: url)

            // Método para passar os dados para este arquivo via POST
            requisicao.httpMethod = "POST"
            
            // Campos a serem adicionados na url
            let body = "nomeUsuario=\(nomeUsuario.lowercased())&senha=\(senha)&email=\(email)&nomeCompleto=\(nome)%20\(sobrenome)"
            
            // Suporte para todos os idiomas
            requisicao.httpBody = body.data(using: .utf8)
            
            // Processar o envio da requisição
            URLSession.shared.dataTask(with: requisicao) { (data, response, error) in
                
                // Se não tiver erro
                if error == nil {
                    
                    // Obter a fila principal para executer este bloco
                    DispatchQueue.main.async(execute: {
                        do {
                            
                            // Obter o resultado JSON
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                            
                            // Enviar o objeto JSON para guardar em uma constante
                            guard let parseJSON = json else {
                                print("\nErro ao tentar fazer o parse do JSON\n")
                                return
                            }
                            
                            // Obter id a partir do dicionário parseJSON
                            let id = parseJSON["id"]
                            
                            // Sucesso no registro do usuário
                            if id != nil {
                                
                                // Salvar informações do usuário
                                UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                                usuario = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                                
                                // Apresentar tabBar view / página inicial
                                DispatchQueue.main.async(execute: {
                                    appDelegate.entrar()
                                })                                
                                
                            }
                            // Ocorreu um erro
                            else {
                                // Obter a fila principal para executer este bloco
                                DispatchQueue.main.async(execute: {
                                    let mensagem = parseJSON["mensagem"] as! String
                                    appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                                })
                                return
                            }
                        }
                        catch {
                            // Obter a fila principal para executer este bloco
                            DispatchQueue.main.async(execute: {                                
                                let mensagem = String(describing: error)
                                appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                            })
                            return
                        }
                    })
                }
                // Erro na requisição
                else {
                    // Obter a fila principal para executer este bloco
                    DispatchQueue.main.async(execute: {
                        let mensagem = error!.localizedDescription
                        appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                    })
                    return
                }
            }.resume()
        }
    }
    
    // Status bar em branco
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // Quando usuário tocar na tela
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Esconder o teclado
        self.view.endEditing(false)
    }
}

