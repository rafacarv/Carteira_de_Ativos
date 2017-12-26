//
//  DetalhesAtivos.swift
//  Apenas Testando
//
//  Created by Rafael C F Leite on 04/11/2017.
//  Copyright © 2017 Rafael C F Leite. All rights reserved.
//

import UIKit
import ChameleonFramework

protocol RemoveOperacao {
    func removeOperacao (indice: Int)
}

class DetalhesAtivos: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var quantidadeTotalLabel: UILabel!
    @IBOutlet weak var precoMedioLabel: UILabel!
    @IBOutlet weak var valorTotalLabel: UILabel!
    @IBOutlet weak var precoVendaLabel: UILabel!
    @IBOutlet weak var custoLabel: UILabel!
    @IBOutlet weak var resultadoLiquidoLabel: UILabel!
    @IBOutlet weak var resultadoPercentualLabel: UILabel!
    @IBOutlet weak var custoAquisicaoLabel: UILabel!
    @IBOutlet weak var vendaTotalLabel: UILabel!
    
    
    @IBOutlet weak var listaOperacoes: UITableView!
    
    var todasAsOperacoes: [Operacao] = []
    var nomeDoAtivo : String = ""
    var delegate : RemoveOperacao?
    
    var precoDeMercado : Float = 10
    var quantidadeTotal: Int = 0
    var precoMedio: Float = 0
    var precoVenda: Float = 1
    var custoVenda: Float = 0
    var custoAquisicao: Float = 0
        
    override func viewWillAppear(_ animated: Bool) {
        listaOperacoes.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = (nomeDoAtivo)
        
        listaOperacoes.dataSource = self
        listaOperacoes.delegate = self
        listaOperacoes.register(UINib(nibName: "OperacoesDoAtivo", bundle: nil), forCellReuseIdentifier: "standardCellOperacoes")
        
        listaOperacoes.estimatedRowHeight = 85
        listaOperacoes.rowHeight = UITableViewAutomaticDimension
        
        precoVenda = precoDeMercado
        let custoVenda = calculaCustos(qty: Float(quantidadeTotal), preco: precoVenda)
        let valorTotal = Float(quantidadeTotal)*precoMedio
        let vendaTotal = Float(quantidadeTotal)*precoVenda
        let resultadoLiquido = vendaTotal-valorTotal-custoAquisicao-custoVenda
        let resultadoPercentual = resultadoLiquido / valorTotal * 100
        
        print("Resultado percentual \(resultadoPercentual)")
        
        precoMedioLabel.text = String(format: "R$ %.2f", precoMedio)
        quantidadeTotalLabel.text = String(quantidadeTotal)
        valorTotalLabel.text = String(format: "R$ %.2f", valorTotal)
        precoVendaLabel.text = String(format: "R$ %.2f", precoVenda)
        custoLabel.text = String(format: "R$ %.2f", custoVenda)
        custoAquisicaoLabel.text = String(format: "R$ %.2f", custoAquisicao)
        vendaTotalLabel.text = String(format: "R$ %.2f", vendaTotal)
        resultadoLiquidoLabel.text = String(format: "R$ %.2f", resultadoLiquido)
        resultadoPercentualLabel.text = String(format: "%.1f", resultadoPercentual)+"%"
    }
    
    
    func calculaCustos (qty: Float, preco: Float) -> Float {
        
        let custoCorretagem : Float = 18.9
        let custoISS : Float = 1.82
        let custoIR : Float = 0
        let custoOutras : Float = 0.73
        let custoLiquidacao : Float = qty * preco * 0.0002734
        let custoEmolumento : Float = qty * preco * 0.00004910714286
        
        let custoOperacao = custoCorretagem + custoISS + custoIR + custoOutras + custoLiquidacao + custoEmolumento
        
        return custoOperacao
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return todasAsOperacoes.count
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        todasAsOperacoes.remove(at: indexPath.row)
        
        let indice = [indexPath]
        listaOperacoes.deleteRows(at: indice, with: .right)
        delegate?.removeOperacao(indice: indexPath.row)

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configura o formato da data que vai aparecer
        //
        let formatoData = DateFormatter()
        formatoData.dateFormat = ("dd-mm-yyyy")
        formatoData.locale = Locale(identifier: "pt_BR")
        formatoData.dateStyle = .short
        formatoData.timeStyle = .none
        
        // Le a matriz que contem as operações
        //
        let cell = tableView.dequeueReusableCell(withIdentifier: "standardCellOperacoes", for: indexPath) as! OperacoesDoAtivo
        let listaDasOperacoes = todasAsOperacoes[indexPath.row]
        
        // Cria as celulas
        //
        
        if listaDasOperacoes.tipoOperacao == "C"{
            cell.compraVendaLabel.text = "Compra"
            cell.compraVendaLabel.textColor = UIColor.flatGreen()
            //cell.fundoCelula.backgroundColor = UIColor.flatForestGreenColorDark()
        }
        else {
            cell.compraVendaLabel.text = "Venda"
            cell.compraVendaLabel.textColor = UIColor.flatOrange()
            //cell.fundoCelula.backgroundColor = UIColor.flatOrangeColorDark()
        }
        
        cell.dataOperacaoLabel.text = formatoData.string(from: listaDasOperacoes.dataOperacao)
        cell.quantidadeOperacaoLabel.text = String(listaDasOperacoes.quantidadeAcoes)
        cell.precoAcaoLabel.text = "R$ "+String(format: "%.2f", listaDasOperacoes.precoUnitario)
        cell.custoOperacaoLabel.text = "R$ "+String(format: "%.2f", listaDasOperacoes.custoOperacao)
        cell.custoTotalLabel.text = "R$ "+String(format: "%.2f", listaDasOperacoes.custoOperacao + (listaDasOperacoes.precoUnitario * Float(listaDasOperacoes.quantidadeAcoes)))
        
        return cell
    }
    

}
