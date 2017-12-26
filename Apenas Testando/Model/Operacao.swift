//
//  Operacao.swift
//  Apenas Testando
//
//  Created by Rafael C F Leite on 29/10/2017.
//  Copyright © 2017 Rafael C F Leite. All rights reserved.
//

import Foundation

class Operacao {
    let codigoAcao :String
    let quantidadeAcoes : Int
    let precoUnitario : Float
    let tipoOperacao : String
    let dataOperacao : Date
    let nomeAtivo : String
    let custoOperacao : Float
    
    init (cod: String, qty: Int, preco: Float, operacao: String, data: Date, nome: String, custo: Float){
        codigoAcao = cod
        quantidadeAcoes = qty
        precoUnitario = preco
        tipoOperacao = operacao
        dataOperacao = data
        nomeAtivo = nome
        custoOperacao = custo
    }
}
