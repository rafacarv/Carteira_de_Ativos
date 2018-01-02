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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Mark :- Declaracao das constantes e variaveis
    
    var todasAsOperacoes : [Operacao] = []
    var ativoSelecionado : String = ""
    var nomeSelecionado : String = ""
    
    var quantidadeTotal: Int = 0
    var precoMedio: Float = 0
    var custoAquisicao: Float = 0
    var cotacoes: [String:Float] = [:]
    var ultimaCotacao: Float = 0
    
    var listaOperacoes = [Operacao]()
    var carteiraAcoes = [CarteiraDeAcoes]()
    var nomeAtivo : String = ""
    
    var menuAberto = false
    
    
    @IBOutlet weak var acoesTableView: UITableView!
    @IBOutlet weak var leadingConstraintMenu: NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var leadingConstraintMainView: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraintMainView: NSLayoutConstraint!
    
    @IBAction func unwindToViewController (segue: UIStoryboardSegue){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        acoesTableView.delegate = self
        acoesTableView.dataSource = self
        acoesTableView.register(UINib(nibName: "StandardStockListCell", bundle: nil), forCellReuseIdentifier: "standardCell")

        
        let backgroundGradientColors:[UIColor] = [UIColor.init(hexString: "#3d3d3d")!,UIColor.init(hexString: "#6FDBFD")!]
        view.backgroundColor = UIColor.init(gradientStyle: .topToBottom, withFrame: view.frame, andColors: backgroundGradientColors)
        
//        self.navigationController?.hidesNavigationBarHairline = true
        
        menuView.layer.shadowOpacity = 1
        menuView.layer.shadowRadius = 3
        menuView.layer.cornerRadius = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        carregaCoreData()
        consolidaAcoes()
        acoesTableView.reloadData()
    }

    @IBAction func botaoMenuPressionado(_ sender: UIBarButtonItem) {
        
        if !menuAberto {
            leadingConstraintMenu.constant = 0
            
//            let tamanhoMainView = trailingConstraintMainView.constant - leadingConstraintMainView.constant
//            leadingConstraintMainView.constant = 210
//            trailingConstraintMainView.constant += tamanhoMainView
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            leadingConstraintMenu.constant = -210
//            leadingConstraintMainView.constant = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        menuAberto = !menuAberto
    }
    
    //
    //MARK: - Carrega base de dados
    
    func carregaCoreData() {
        
        listaOperacoes = []
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Operacoes")
        
        do {
            
            let operacoes = try context.fetch(requisicao)
            
            if operacoes.count > 0 {
                
                for oper in operacoes as! [NSManagedObject] {
                    
                    let cod = oper.value(forKey: "codigo") as! String
                    let qty = oper.value(forKey: "quantidade") as! Int
                    let preco = oper.value(forKey: "preco") as! Float
                    let operacao = oper.value(forKey: "operacao") as! String
                    let data = oper.value(forKey: "data") as! Date
                    let nome = oper.value(forKey: "nome") as! String
                    let custo = oper.value(forKey: "custo") as! Float
                    
                    listaOperacoes.append(Operacao(cod: cod, qty: qty, preco: preco, operacao: operacao, data: data, nome: nome, custo: custo))
                }
            } else {
                print("O Modelo esta vazio!")
            }
            ordenaPorData()
            
        } catch {
            print("Falha ao carregar dados do modelo!")
        }
    }
    
    //MARK: - Consolida as operações nas matrizes
    
    func consolidaAcoes () {
        
        var ativos : Set<String> = []
        var precoMedio : Float = 0
        
        carteiraAcoes = []
        ordenaPorData()
        
        for items in listaOperacoes {
            ativos.insert(items.codigoAcao)
        }
        
        for ativo in ativos {
            var qtyTotal: Int = 0
            var custo : Float = 0
            
            for operacao in listaOperacoes where operacao.codigoAcao == ativo {
                
                    nomeAtivo = operacao.nomeAtivo
                    if operacao.tipoOperacao == "C"{
                        if precoMedio == 0 {
                            precoMedio = operacao.precoUnitario
                        } else {
                            precoMedio = ((precoMedio * Float(qtyTotal)) + (operacao.precoUnitario * Float(operacao.quantidadeAcoes)))/Float((qtyTotal+operacao.quantidadeAcoes))
                        }
                        qtyTotal += operacao.quantidadeAcoes
                        custo += operacao.custoOperacao
                    }
                    else if operacao.tipoOperacao == "V"{
                        qtyTotal -= operacao.quantidadeAcoes
                        custo -= operacao.custoOperacao
                        if qtyTotal == 0 {
                            print("O ativo \(ativo) zerou!")
                            precoMedio = 0
                            custo = 0
                        }
                    }
            }
            if qtyTotal != 0 {
                carteiraAcoes.append(CarteiraDeAcoes(cod: ativo, nome: nomeAtivo, qty: qtyTotal, preco: precoMedio, custo: custo))
            }
        }
    }
    
    func ordenaPorData () {
        listaOperacoes.sort(by: { $0.dataOperacao < $1.dataOperacao})
    }
    
    //
    //MARK: - Monta a Tabela de ativos na carteira

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carteiraAcoes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "standardCell", for: indexPath) as! StandardStockListCell
        let informacaoCompletaAcao = carteiraAcoes[indexPath.row]
        
        cell.codigoTextField.text = informacaoCompletaAcao.codigoAcao
        cell.nomeTextField.text = informacaoCompletaAcao.nomeAcao
        cell.quantidadeTotal.text = String(informacaoCompletaAcao.quantidadeTotal)
        cell.precoMedioLabel.text = "R$ "+String(format: "%.2f", informacaoCompletaAcao.precoMedio)
        
        cell.acoesView.layer.cornerRadius = 8
//        cell.acoesView.layer.shadowRadius = 4
//        cell.acoesView.layer.shadowOpacity = 1
        cell.acoesView.layer.masksToBounds = true
        
        buscaCotacao(ativo: informacaoCompletaAcao.codigoAcao, for: cell, indexPath: indexPath)
        
        return cell
    }
    
    //
    // MARK: - Quando um ativo da carteira for selecionado manda para a tela de detalhes
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let linhaSelecionada = tableView.indexPathForSelectedRow {
        
            ativoSelecionado = carteiraAcoes[linhaSelecionada.row].codigoAcao
            nomeSelecionado = carteiraAcoes[linhaSelecionada.row].nomeAcao
            quantidadeTotal = carteiraAcoes[linhaSelecionada.row].quantidadeTotal
            precoMedio = carteiraAcoes[linhaSelecionada.row].precoMedio
            custoAquisicao = carteiraAcoes[linhaSelecionada.row].custoAquisicao
            
            if let u = cotacoes[carteiraAcoes[linhaSelecionada.row].codigoAcao] {
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
            _ = segue.destination as! addStockViewController
        }
        else if segue.identifier == "showDetail" {
            let showDetailVC = segue.destination as! DetalhesAtivos
            
            consolidaOperacoes(ativo: ativoSelecionado)
            showDetailVC.todasAsOperacoes = todasAsOperacoes
            showDetailVC.codigoDoAtivo = ativoSelecionado
            showDetailVC.nomeDoAtivo = nomeSelecionado
            showDetailVC.quantidadeTotal = quantidadeTotal
            showDetailVC.precoMedio = precoMedio
            showDetailVC.custoAquisicao = custoAquisicao
            showDetailVC.precoDeMercado = ultimaCotacao
        }
    }
    
    //
    //MARK: - Funções que consolidam o que há na carteira
    
    func consolidaOperacoes (ativo: String) {
        todasAsOperacoes = []
        for c in listaOperacoes {
            if c.codigoAcao == ativo {
                todasAsOperacoes.append(Operacao(cod: c.codigoAcao, qty: c.quantidadeAcoes, preco: c.precoUnitario, operacao: c.tipoOperacao, data: c.dataOperacao, nome: c.nomeAtivo, custo: c.custoOperacao))
            }
        }
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

