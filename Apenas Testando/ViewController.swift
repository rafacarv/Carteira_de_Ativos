//
//  ViewController.swift
//  Apenas Testando
//
//  Created by Rafael C F Leite on 15/10/2017.
//  Copyright © 2017 Rafael C F Leite. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddStock, RemoveOperacao {
    
    // Mark :- Declaracao das constantes e variaveis
    
    let operacoesAcoes = ListaOperacoes()
    var todasAsOperacoes : [Operacao] = []
    var ativoSelecionado : String = ""
    var nomeSelecionado : String = ""
    var quantidadeTotal: Int = 0
    var precoMedio: Float = 0
    var custoAquisicao: Float = 0
    var cotacoes: [String:Float] = [:]
    var ultimaCotacao: Float = 0
    
    @IBOutlet weak var acoesTableView: UITableView!
    
    @IBAction func unwindToViewController (segue: UIStoryboardSegue){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.navigationBar.isTranslucent = true
//        navigationController?.navigationBar.prefersLargeTitles = false
        
//        if let carteiraSalva = UserDefaults.standard.object(forKey: "carteira") {
//            operacoesAcoes.carteiraAcoes = carteiraSalva as! [CarteiraDeAcoes] }
//        else{
//            operacoesAcoes.carteiraAcoes = []
//        }
        
        acoesTableView.delegate = self
        acoesTableView.dataSource = self
        acoesTableView.register(UINib(nibName: "StandardStockListCell", bundle: nil), forCellReuseIdentifier: "standardCell")
        
        operacoesAcoes.consolidaAcoes()
        
        let backgroundImage = UIImage(named: "puppy-dark-love-wallpaper")
        let imageView = UIImageView(image: backgroundImage)
        acoesTableView.backgroundView = imageView
        
        acoesTableView.reloadData()
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operacoesAcoes.carteiraAcoes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "standardCell", for: indexPath) as! StandardStockListCell
        let informacaoCompletaAcao = operacoesAcoes.carteiraAcoes[indexPath.row]
        
        cell.codigoTextField.text = informacaoCompletaAcao.codigoAcao
        cell.nomeTextField.text = informacaoCompletaAcao.nomeAcao
        cell.quantidadeTotal.text = String(informacaoCompletaAcao.quantidadeTotal)
        cell.precoMedioLabel.text = "R$ "+String(format: "%.2f", informacaoCompletaAcao.precoMedio)
  
        buscaCotacao(ativo: informacaoCompletaAcao.codigoAcao, for: cell, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let linhaSelecionada = tableView.indexPathForSelectedRow {
        
            ativoSelecionado = operacoesAcoes.carteiraAcoes[linhaSelecionada.row].codigoAcao
            nomeSelecionado = operacoesAcoes.carteiraAcoes[linhaSelecionada.row].nomeAcao
            quantidadeTotal = operacoesAcoes.carteiraAcoes[linhaSelecionada.row].quantidadeTotal
            precoMedio = operacoesAcoes.carteiraAcoes[linhaSelecionada.row].precoMedio
            custoAquisicao = operacoesAcoes.carteiraAcoes[linhaSelecionada.row].custoAquisicao
            
            if let u = cotacoes[operacoesAcoes.carteiraAcoes[linhaSelecionada.row].codigoAcao] {
                print("ultimacotacao = \(u)")
                self.ultimaCotacao = u
            } else {
                ultimaCotacao = 1
            }
            
            acoesTableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "showDetail", sender: self)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addStock" {
            let addStockVC = segue.destination as! addStockViewController
            addStockVC.delegate = self
            
        }
        else if segue.identifier == "showDetail" {
            let showDetailVC = segue.destination as! DetalhesAtivos
            consolidaOperacoes(ativo: ativoSelecionado)
            showDetailVC.todasAsOperacoes = todasAsOperacoes
            showDetailVC.nomeDoAtivo = nomeSelecionado
            showDetailVC.quantidadeTotal = quantidadeTotal
            showDetailVC.precoMedio = precoMedio
            showDetailVC.custoAquisicao = custoAquisicao
            showDetailVC.precoDeMercado = ultimaCotacao
            
            showDetailVC.delegate = self
            
        }
    }
    
    func consolidaOperacoes (ativo: String) {
        todasAsOperacoes = []
        
        for c in operacoesAcoes.listaOperacoes {
            if c.codigoAcao == ativo {
                todasAsOperacoes.append(Operacao(cod: c.codigoAcao, qty: c.quantidadeAcoes, preco: c.precoUnitario, operacao: c.tipoOperacao, data: c.dataOperacao, nome: c.nomeAtivo, custo: c.custoOperacao))
            }
        }
    }
    
    // Mark: - Funcoes ligadas a protocolos
    //
    
    func addStockToWallet (codigo: String, nome: String, qty: Int, preco: Float, oper: String, data: Date, custo: Float) {
        operacoesAcoes.addAcao(cod: codigo, qty: qty, preco: preco, operacao: oper, data: data, nome: nome, custo: custo)
        print("Codigo: \(codigo) Quantidade: \(qty) Preço: \(preco) Tipo da Operacao: \(oper) Data \(data)")
        acoesTableView.reloadData()
    }
    
    func removeOperacao (indice: Int) {
        
        var contador = 0
        var contadorMaster = 0
        var dataOperacaoRemover: Date = Date(timeIntervalSinceReferenceDate: 410220000)
        
        
        for c in operacoesAcoes.listaOperacoes {
            if c.codigoAcao == ativoSelecionado {
                if contador == indice{
                    dataOperacaoRemover = c.dataOperacao
                    operacoesAcoes.listaOperacoes.remove(at: contadorMaster)
                }
            contador = contador+1
            }
        contadorMaster = contadorMaster+1
        }
        
        //Mark: -Remover do CoreData
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Operacoes")
        
        let predicate = NSPredicate(format: "data == %@", dataOperacaoRemover as CVarArg)
        requisicao.predicate = predicate
        
        
        do {
            let operacoes = try context.fetch(requisicao) as! [NSManagedObject]
            if operacoes.count == 1 {
                
                for operacao in operacoes {
                    print (operacao.value(forKey: "codigo")!)
                    print (operacao.value(forKey: "data")!)
                    print("Sucesso em encontrar o item a ser removido!")
                    context.delete(operacao)
                    
                    do {
                        try context.save()
                        print ("Sucesso ao remover o item do CoreData")
                    } catch  {
                        print ("Falha ao tentar salvar após delete.")
                    }
                }
            } else {
                print("ALERTA! O SISTEMA ENCONTROU MAIS DE UM REGISTRO PARA REMOVER!!! BIZARRO!")
            }
        } catch {
            print("Erro ao encontrar o registro para remover")
        }
        
        operacoesAcoes.consolidaAcoes()
        acoesTableView.reloadData()
    }
    
    // MARK: - Consulta cotação do ativo
    
    func buscaCotacao (ativo: String, for cell: StandardStockListCell, indexPath: IndexPath) {
        
        let finalURL = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&interval=1min&apikey=SPCSU10VD5DP921G&outputsize=compact&symbol=" + ativo
        
        Alamofire.request(finalURL, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let resultadoJSON : JSON = JSON(response.result.value!)
                    
                    if let resultado = Float (self.parseResultado(json: resultadoJSON)) {
                        cell.precoAtualLabel.text = "R$ "+String(format: "%.2f", resultado)
                        self.cotacoes[ativo] = resultado}
                    else{
                        cell.precoAtualLabel.text = "N/D"
                        self.cotacoes[ativo] = 0
                    }
                } else {
                    cell.precoAtualLabel.text = "N/D"
                    print("Error: \(response.result.error!)")
                }
            }
    }
    
    func parseResultado(json: JSON) -> String {
        if let lastRefreshed = json["Meta Data"]["3. Last Refreshed"].string {
            if let valorUltimo = json["Time Series (1min)"][lastRefreshed]["4. close"].string {
                return valorUltimo
            }
            else {
                return "Erro"
            }
        }
        else {
            return "Erro"
        }
    }
}

