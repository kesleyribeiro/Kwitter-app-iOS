//
//  HomeVC.swift
//  Kwitter
//
//  Created by Kesley Ribeiro on 18/Mar/17.
//  Copyright © 2017 AppaoCubo. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    // Objetos da view
    @IBOutlet weak var imagemPerfil: UIImageView!
    @IBOutlet weak var nomeUsuarioLabel: UILabel!
    @IBOutlet weak var nomeCompletoLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var editarButton: UIButton!
    

    // Objetos da view relacionados aos Posts
    @IBOutlet weak var kweetsTableView: UITableView!
    var kweets = [AnyObject]()
    var imagens = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Obter informações do usuário a partir da variável global
        let nomeUsuario = (usuario!["nomeUsuario"] as AnyObject).uppercased
        let nomeCompleto = usuario!["nomeCompleto"] as? String
        let email = usuario!["email"] as? String
        let ava = usuario!["ava"] as? String

        // Atribuir para as constantes os valores informados pelo usuário
        nomeUsuarioLabel.text = nomeUsuario
        nomeCompletoLabel.text = nomeCompleto
        emailLabel.text = email
        
        // Obter imagem de perfil do usuário
        if ava != "" {
            
            // url path para a imagem
            let urlImagem = URL(string: ava!)!

            // Obter a fila principal para executar este bloco
            DispatchQueue.main.async(execute: {
                
                // Obter o dado a partir da urlImage
                let dadoImagem = try? Data(contentsOf: urlImagem)
                
                // Se os dados não são nill atribuir ao imagemPerfil.image
                if dadoImagem != nil {
                    DispatchQueue.main.async(execute: {
                        self.imagemPerfil.image = UIImage(data: dadoImagem!)
                    })
                }
            })
        }

        // Arredondar bordas da imagem
        imagemPerfil.layer.cornerRadius = imagemPerfil.bounds.width / 20
        imagemPerfil.clipsToBounds = true
        
        // Definir a cor do botão Editar
        editarButton.setTitleColor(corAzul, for: .normal)
        
        // Definir o título da view com o nome de usuário
        self.navigationItem.title = nomeUsuario

        // Criar uma linha para separar o perfil do usuário e os Posts da tableView
        kweetsTableView.contentInset = UIEdgeInsetsMake(2, 0, 0, 0)
    }
    
    // Função executada enquanto a view é carregada
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Chamar a função de carregar os Posts
        carregarPosts()
    }
    
    // Botão Editar perfil
    @IBAction func editarPerfil(_ sender: Any) {

        // Declarar alerta do tipo actionSheet
        let alerta = UIAlertController(title: "Editar perfil", message: nil, preferredStyle: .actionSheet)
        
        // Botão Cancelar
        let btnCancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        // Botão Mudar imagem
        let btnMudarImagem = UIAlertAction(title: "Mudar imagem", style: .default) { (action:UIAlertAction) in
            self.selecionarImagemPerfil()
        }
        
        // Botão Atualizar perfil
        let btnAtualizarPerfil = UIAlertAction(title: "Atualizar perfil", style: .default) { (action:UIAlertAction) in

            // Declara variável editarVC para guardar scene a partir do main.storyboard
            let editarVC = self.storyboard!.instantiateViewController(withIdentifier: "EditarVC") as! EditarVC
            self.navigationController?.pushViewController(editarVC, animated: true)
            
            // Remover o título do botão voltar
            let botaoVoltar = UIBarButtonItem()
            botaoVoltar.title = ""
            self.navigationItem.backBarButtonItem = botaoVoltar
        }

        // Adicionar as ações (botões) na actionSheet
        alerta.addAction(btnCancelar)
        alerta.addAction(btnMudarImagem)
        alerta.addAction(btnAtualizarPerfil)

        // Apresentar action sheet na view
        self.present(alerta, animated: true, completion: nil)
    }
    
    // Selecionar imagem do perfil
    func selecionarImagemPerfil() {

        // Criar um pickerController para selecionar a imagem no celular
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }

    // Imagem foi selecionada no pickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        imagemPerfil.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)

        // Chamar a função para fazer upload da imagem
        uploadImagemPerfil()
    }
    
    // Atualizar imagem para o servidor
    func uploadImagemPerfil() {
        
        // Obter id a partir do dicionário parseJSON
        let id = usuario!["id"] as! String
        
        // URL para o arquivo PHP
        let url = URL(string: "http://localhost/Kwitter/uploadImagemPerfil.php")!
        
        // Requisição para este arquivo
        var requisicao = URLRequest(url: url)
        
        // Método para passar os dados para este arquivo via POST
        requisicao.httpMethod = "POST"
        
        // Parâmetro para ser passado ao arquivo PHP
        let param = ["id": id]
        
        // Body
        let limite = "Boundary-\(UUID().uuidString)"
        requisicao.setValue("multipart/form-data; boundary=\(limite)", forHTTPHeaderField: "Content-Type")

        // Se imagem foi selecionada, comprimir para enviar
        let imagemDado = UIImageJPEGRepresentation(imagemPerfil.image!, 0.5)
        
        // Se não comprimir. return...não continua o código
        if imagemDado == nil {
            return
        }
        
        // ... Body
        requisicao.httpBody = criarBodyComParametros(param, chavePathArquivo: "arquivo", chaveDadosImagem: imagemDado!, limite: limite)

        // Processar o envio da requisição
        URLSession.shared.dataTask(with: requisicao) { (data, response, error) in

            // Obter a fila principal para executar este bloco
            DispatchQueue.main.async(execute: {
                
                // // Se não tiver erro
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
                        
                        // Sucesso no upload da imagem
                        if id != nil {
                            
                            // Salvar informações do usuário
                            UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                            usuario = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                            
                        } // Se não conseguir retorno com o id do usuário
                        else {
                            // Obter a fila principal para executar este bloco
                            DispatchQueue.main.async(execute: {
                                let mensagem = parseJSON["mensagem"] as! String
                                appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                            })
                        }
                    }
                    // Erro ao fazer JSON
                    catch {
                        // Obter a fila principal para executar este bloco
                        DispatchQueue.main.async(execute: {
                            let mensagem = error as! String
                            appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                        })
                    }
                    
                } // Erro na requisição
                else {
                    // Obter a fila principal para executar este bloco
                    DispatchQueue.main.async(execute: {
                        let mensagem = error!.localizedDescription
                        appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                    })
                }
            })
        }.resume()
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
        
        let nomeArquivo = "ava.jpg"
        
        let mimetype = "imagem/jpg"
        
        body.adicionarString("--\(limite)\r\n")
        body.adicionarString("Content-Disposition: form-data; name=\"\(chavePathArquivo!)\"; nomeArquivo=\"\(nomeArquivo)\"\r\n")
        body.adicionarString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(chaveDadosImagem)
        body.adicionarString("\r\n")
        
        body.adicionarString("--\(limite)--\r\n")

        return body as Data
    }
    
    // Botão Sair (lougout)
    @IBAction func sairButton(_ sender: Any) {
    
        // Remover informações salvas
        UserDefaults.standard.removeObject(forKey: "parseJSON")
        UserDefaults.standard.synchronize()
        
        // Voltar para a página de Entrar (Login)
        let entrarVC = self.storyboard?.instantiateViewController(withIdentifier: "EntrarVCID") as! EntrarVC
        self.present(entrarVC, animated: true, completion: nil)
    }
    
    // TABLE VIEW
    // Números de Cell na TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kweets.count
    }
    
    // Configuração da Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        let kweet = kweets[indexPath.row]
        let imagem = imagens[indexPath.row]
        let nomeUsuario = kweet["nomeUsuario"] as? String
        let texto = kweet["texto"] as? String
        let data = kweet["data"] as! String
        
        // Converter String data para data
        let formatarData = DateFormatter()
        formatarData.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let novaData = formatarData.date(from: data)!
        
        // Declarar ajustes
        let aPartir = novaData
        let agora = Date()
        let componentes : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let diferenca = (Calendar.current as NSCalendar).components(componentes, from: aPartir, to: agora, options: [])
        
        // Calcular a data do Post
        if diferenca.second! <= 0 {
            cell.dataPostLabel.text = "Agora"
        }
        if diferenca.second! > 0 && diferenca.minute! == 0 {
            cell.dataPostLabel.text = "\(diferenca.second)s." // Ex: 10s.
        }
        if diferenca.minute! > 0 && diferenca.hour! == 0 {
            cell.dataPostLabel.text = "\(diferenca.minute)m." // Ex: 2m.
        }
        if diferenca.hour! > 0 && diferenca.day! == 0 {
            cell.dataPostLabel.text = "\(diferenca.hour)h." // Ex: 4h.
        }
        if diferenca.day! > 0 && diferenca.weekOfMonth! == 0 {
            cell.dataPostLabel.text = "\(diferenca.day)d." // 1d.
        }
        if diferenca.weekOfMonth! > 0 {
            cell.dataPostLabel.text = "\(diferenca.weekOfMonth)w." // Ex: 2W. (semanas)
        }
        
        // Atribuir valores para objetos da view
        cell.nomeUsuarioLabel.text = nomeUsuario
        cell.textoPostLabel.text = texto
        cell.imagemPost.image = imagem
        
        // Obter a fila principal para executar este bloco
        DispatchQueue.main.async {
            
            // Se não tiver imagem na Cell
            if imagem.size.width == 0 && imagem.size.height == 0 {
                
                // Mover o textoPostLabel para a esquerda se o Post não tiver com foto
                cell.textoPostLabel.frame.origin.x = self.view.frame.size.width / 16 // = 20
                cell.textoPostLabel.frame.size.width = self.view.frame.size.width - self.view.frame.size.width / 8 // = 40
                cell.textoPostLabel.sizeToFit()
            }
        }

        return cell
    }
    
    
    // Função para buscar no BD todos os Posts do usuário e mostrar no app
    func carregarPosts() {

        // Atrbuir para a variável o id do usuário
        let id = usuario!["id"] as! String
        
        // URL para o arquivo PHP
        let url = URL(string: "http://localhost/Kwitter/posts.php")!
        
        // Requisição para este arquivo
        var requisicao = URLRequest(url: url)
        
        // Método para passar os dados para este arquivo via POST
        requisicao.httpMethod = "POST"

        // Campos a serem adicionados na url
        let body = "id=\(id)&texto=&uuid="
        
        // Suporte para todos os idiomas
        requisicao.httpBody = body.data(using: .utf8)
        
        // Processar o envio da requisição
        URLSession.shared.dataTask(with: requisicao) { (data, response, error) in
            
            // Obter a fila principal para executar este bloco
            DispatchQueue.main.async(execute: {
                
                // Se não tiver erro
                if error == nil {                    
                    do {
                        
                        // Obter o resultado JSON
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        // Limpar
                        self.kweets.removeAll(keepingCapacity: false)
                        self.imagens.removeAll(keepingCapacity: false)
                        self.kweetsTableView.reloadData()
                        
                        // Enviar o objeto JSON para guardar em uma constante
                        guard let parseJSON = json else {
                            print("\nOcorreu um erro ao tentar o parse JSON: \(error)")
                            return
                        }
                        
                        // Declara uma variável post para guardar os postos do parseJSON
                        guard let posts = parseJSON["posts"] as? [AnyObject] else {
                            print("\nOcorreu um erro ao tentar o parse JSON: \(error)")
                            return
                        }
                        
                        // Atribuir para a variável kweets todas as informações dos Posts
                        self.kweets = posts

                        // Obter as imagens a partir do path url
                        for i in 0 ..< self.kweets.count {
                            
                            // Criar um path para obter os dados via $arrayRetorno que foi atribuído ao parseJSON > posts > kweets
                            let path = self.kweets[i]["path"] as? String
                            
                            // Se encontrar o path
                            if !path!.isEmpty {

                                let url = URL(string: path!)! // Converter a url para string path
                                let dadoImagem = try? Data(contentsOf: url) // Obter o dado via url e atribuir para dadoImagem
                                let imagem = UIImage(data: dadoImagem!)! // Obter a imagem via dadoImagem
                                self.imagens.append(imagem) // Adicionar a imagem encontrada para var imagens

                            } // Se não encontrar o path
                            else {
                                let image = UIImage() // Se não encontrar o path, criar um do tipo UIImage
                                self.imagens.append(image) // Adicionar a imagem encontrada para var imagens para enviar crash
                            }
                        }
                        
                        self.kweetsTableView.reloadData() // Recarregar as informações da tableView

                    } catch {
                        // Obter a fila principal para executar este bloco
                        DispatchQueue.main.async(execute: {
                            let mensagem = "\(error)"
                            appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                        })
                        return
                    }
                } // Erro na requisição
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
    
    // SESSÃO APAGAR POST
    // Obter a Cell
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Se usuário fizer movimento Swipe na Cell
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Se precionado o botão Apagar post via swipe na Cell
        let acaoApagar =  UITableViewRowAction(style: .normal , title: "Apagar post") {  action, index in

            // Enviar requisição PHP para apagar Post
            self.apagarPost(indexPath)
        }
        acaoApagar.backgroundColor = .red
        
        return [acaoApagar]
    }
    
    // Função para apagar Post
    func apagarPost(_ indexPath : IndexPath) {
        
        let kweet = kweets[indexPath.row]
        let uuid = kweet["uuid"] as! String
        let path = kweet["path"] as! String
        
        // Acessar o arquivo PHP
        let url = URL(string: "http://localhost/Kwitter/posts.php")!

        // Declara a requisição para proceder a url
        var requisicao = URLRequest(url: url)
        
        // Método para passar os dados para este arquivo via POST
        requisicao.httpMethod = "POST"
        
        // Campos a serem adicionados na url
        let body = "uuid=\(uuid)&path=\(path)"
        
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

                        // Obter e atribuir em 'resultado' o valor da variável $arrayRetorno["resultado"]
                        let resultado = parseJSON["resultado"]
                        
                        // Se resultado existir - Apagar com sucesso
                        if resultado != nil {

                            self.kweets.remove(at: indexPath.row) // Apagar todo conteúdo relacionado ao array
                            self.imagens.remove(at: indexPath.row) // Apagar relacionado a imagem
                            self.kweetsTableView.deleteRows(at: [indexPath], with: .automatic) // Apagar Cell da tableView
                            self.kweetsTableView.reloadData() // Recarregar dados na tableView para mostrar atualizado

                        } // Se não tiver resultado
                        else {
                            // Obter a fila principal para executar este bloco
                            DispatchQueue.main.async(execute: {
                                let mensagem = parseJSON["mensagem"] as! String
                                appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                            })
                            return
                        }
                    }
                    catch {
                        // Obter a fila principal para executar este bloco
                        DispatchQueue.main.async(execute: {
                            let mensagem = "\(error)"
                            appDelegate.infoView(mensagem: mensagem, corAlterada: corAlteradaVermelho)
                        })
                        return
                    }
                }
                // Erro na requisição
                else {
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
}

// Criar protocolo de adicionar string para variável do tipo data
extension NSMutableData {
    
    func adicionarString(_ string: String) {
        
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
