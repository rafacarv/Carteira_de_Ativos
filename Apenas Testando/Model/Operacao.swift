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
    let custoCorretagem : Float
    let custoLiquidacao : Float
    let custoEmolumento: Float
    let custoISS : Float
    let custoOutras : Float
    
    init (cod: String, qty: Int, preco: Float, operacao: String, data: Date, nome: String, corretagem : Float, liquidacao : Float, emolumento: Float, ISS : Float, outras : Float){
        codigoAcao = cod
        quantidadeAcoes = qty
        precoUnitario = preco
        tipoOperacao = operacao
        dataOperacao = data
        nomeAtivo = nome
        custoCorretagem = corretagem
        custoLiquidacao = liquidacao
        custoEmolumento = emolumento
        custoISS = ISS
        custoOutras = outras
    }
}
