//
//  PostVC.swift
//  Kwitter
//
//  Created by Kesley Ribeiro on 20/Mar/17.
//  Copyright © 2017 AppaoCubo. All rights reserved.
//

import UIKit

class PostVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Objetos da view
    @IBOutlet weak var postTxt: UITextView!
    @IBOutlet weak var imagemPost: UIImageView!
    @IBOutlet weak var qtdCaracteresLabel: UILabel!
    @IBOutlet weak var selecionarImagemBtn: UIButton!
    @IBOutlet weak var postarBtn: UIButton!
    
    // Id único do Post
    var uuid = String()
    
    var imagemSelecionada = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Arredondar bordas
        postTxt.layer.cornerRadius = postTxt.bounds.width / 50
        postarBtn.layer.cornerRadius = postarBtn.bounds.width / 25
        imagemPost.layer.cornerRadius = imagemPost.bounds.width / 15
        imagemPost.clipsToBounds = true

        // Cores
        selecionarImagemBtn.setTitleColor(corAzul, for: .normal)
        postarBtn.backgroundColor = corAzul
        qtdCaracteresLabel.textColor = corCinza
        
        // Desabilitar scroll automático do layout
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Desabilitar botão POSTAR quando iniciar view
        postarBtn.isEnabled = false
        postarBtn.alpha = 0.3
    }
    
    // Algum texto foi informado no TextView
    func textViewDidChange(_ textView: UITextView) {
        
        // Número de caracteres no TextView
        let caracteres = textView.text.characters.count
        
        // Enquanto tiver espaço no TextView
        let espaco = NSCharacterSet.whitespacesAndNewlines
        
        // Calcular o tamanho da string e converte para string
        qtdCaracteresLabel.text = String(140 - caracteres)
        
        // Se a quantidade de caracteres for maior que 140
        if caracteres > 140 {
            
            // Mudar o comportamento do botão e a cor da label
            qtdCaracteresLabel.textColor = corAlteradaVermelho
            postarBtn.isEnabled = false
            postarBtn.alpha = 0.3
            
        } // Se for inserido espaço e novas linhas no TextView
        else if textView.text.trimmingCharacters(in: espaco).isEmpty {
            postarBtn.isEnabled = false
            postarBtn.alpha = 0.3
            
        } // Texto informado corretamente
        else {
            qtdCaracteresLabel.textColor = corCinza
            postarBtn.isEnabled = true
            postarBtn.alpha = 1
        }
    }

    // Selecionar imagem para postar
    @IBAction func selecionarImagemPost(_ sender: Any) {
    
        // Selecionar imagem do perfil
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    // Imagem selecionada no picker view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        imagemPost.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // Muda p/ verdadeiro para salvar imagem no servidor
        if imagemPost.image == info[UIImagePickerControllerEditedImage] as? UIImage {
            imagemSelecionada = true
        }
    }
    
    // Requisição HTTP do body customizado para ser feito o upload da imagem
    func criarBodyComParametros(_ parametros: [String: String]?, chavePathArquivo: String?, chaveDadosImagem: Data, limite: String) -> Data {
        
        let body = NSMutableData()
        
        if parametros != nil {

            for (chave, valor) in parametros! {
                body.adicionarString("--\(limite)\r\n")
                body.adicionarString("Content-Disposition: form-data; name=\"\(chave)\"\r\n\r\n")
                body.adicionarString("\(valor)\r\n")
            }
        }
        
        // Se arquivo não for selecionado, não é possível fazer upload para o servidor, pois não está definido o nome do arquivo
        var nomeArquivo = ""
        
        if imagemSelecionada == true {
            nomeArquivo = "post-\(uuid).jpg"
        }
        
        let mimetype = "imagem/jpg"
        
        body.adicionarString("--\(limite)\r\n")
        body.adicionarString("Content-Disposition: form-data; name=\"\(chavePathArquivo!)\"; nomeArquivo=\"\(nomeArquivo)\"\r\n")
        body.adicionarString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(chaveDadosImagem)
        body.adicionarString("\r\n")

        body.adicionarString("--\(limite)--\r\n")
        
        return body as Data
    }
    
    // Função para enviar a requisição para o arquivo PHP
    func uploadPost() {
        
        // Dados para passar ao arquivo PHP
        let id = usuario!["id"] as! String
        uuid = NSUUID().uuidString
        let texto = postTxt.text.trunc(140) as String

        // URL para o arquivo PHP
        let url = URL(string: "http://localhost/Kwitter/posts.php")!
        
        // Requisição para este arquivo
        var requisicao = URLRequest(url: url)
        
        // Método para passar os dados para este arquivo via POST
        requisicao.httpMethod = "POST"
        
        // Parâmetros para serem passados ao arquivo PHP
        let param = ["id": id, "uuid" : uuid, "texto" : texto]
     
        // Body
        let limite = "Boundary-\(UUID().uuidString)"
        
        requisicao.setValue("multipart/form-data; boundary=\(limite)", forHTTPHeaderField: "Content-Type")
        
        // Se imagem foi selecionada, comprimir para enviar
        var imagemDado = Data()
        
        if imagemPost.image != nil {
            imagemDado = UIImageJPEGRepresentation(imagemPost.image!, 0.5)!
        }

        requisicao.httpBody = criarBodyComParametros(param, chavePathArquivo: "arquivo", chaveDadosImagem: imagemDado, limite: limite)

        // Processar o envio da requisição
        URLSession.shared.dataTask(with: requisicao as URLRequest) { (data, response, error) in

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
                        
                        // Obtém uma mensagem a partir do $arrayRetorno["mensagem"]
                        let mensagem = parseJSON["mensagem"]

                        // Se tiver alguma mensagem - Post é realizado
                        if mensagem != nil {
                            print("\nSucesso no Post")

                            // Resetar informações na view
                            self.postTxt.text = ""
                            self.qtdCaracteresLabel.text = "140"
                            self.imagemPost.image = nil
                            self.postarBtn.isEnabled = false
                            self.postarBtn.alpha = 0.3
                            self.imagemSelecionada = false

                            // Switch para outra view - com índice 0
                            self.tabBarController?.selectedIndex = 0                            
                        }
                    } catch {
                        // Obter a fila principal para executar este bloco
                        DispatchQueue.main.async(execute: {
                            let mensagem = "\(error)"
                            appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                        })
                        return
                    }
                } else {
                    // Obter a fila principal para executar este bloco
                    DispatchQueue.main.async(execute: {
                        let mensagem = error!.localizedDescription
                        appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                    })
                    return
                }
            })
        }.resume()
    }
    
    // Botão POSTAR
    @IBAction func postarButton(_ sender: Any) {
    
        // Verificar se há texto e a quantidade de caracteres é igual ou maior que 140 caracteres
        if !postTxt.text.isEmpty && postTxt.text.characters.count <= 140 {
            
            // Habilitar botão POSTAR
            postarBtn.isEnabled = true
            postarBtn.alpha = 1
            
            // Chamar função para fazer upload do Post
            uploadPost()
        }
    }
    
    // Quando usuário tocar na tela
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Esconder o teclado
        self.view.endEditing(false)
    }
}

// Extensão para variáveis do tipo String
extension String {
    
    // cut / trimm of string
    func trunc(_ length: Int, trailing: String? = "...") -> String {
        
        if self.characters.count > length {
            
            return self.substring(to: self.characters.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
        } else {
            return self
        }
    }
}

