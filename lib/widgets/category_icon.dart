import 'package:flutter/material.dart';

IconData getCategoryIcon(String? name) {
  if (name == null || name.trim().isEmpty) {
    return Icons.category_outlined;
  }

  final normalized = name.toLowerCase().trim();

  // Hortifruti
  if (normalized.contains('hortifruti') ||
      normalized.contains('fruta') ||
      normalized.contains('verdura') ||
      normalized.contains('legume') ||
      normalized.contains('vegetal') ||
      normalized.contains('folha')) {
    return Icons.eco_outlined;
  }

  // Açougue e Peixaria
  if (normalized.contains('açougue') ||
      normalized.contains('acougue') ||
      normalized.contains('peixaria') ||
      normalized.contains('carne') ||
      normalized.contains('frango') ||
      normalized.contains('peixe') ||
      normalized.contains('pescado') ||
      normalized.contains('boi') ||
      normalized.contains('suíno') ||
      normalized.contains('suino')) {
    return Icons.restaurant_menu;
  }

  // Padaria e Confeitaria
  if (normalized.contains('padaria') ||
      normalized.contains('confeitaria') ||
      normalized.contains('pão') ||
      normalized.contains('pao') ||
      normalized.contains('bolos') ||
      normalized.contains('bolo') ||
      normalized.contains('torta') ||
      normalized.contains('doce') ||
      normalized.contains('sobremesa')) {
    return Icons.bakery_dining_outlined;
  }

  // Frios e Laticínios
  if (normalized.contains('frios') ||
      normalized.contains('laticínio') ||
      normalized.contains('laticinio') ||
      normalized.contains('laticínios') ||
      normalized.contains('laticinios') ||
      normalized.contains('queijo') ||
      normalized.contains('leite') ||
      normalized.contains('iogurte') ||
      normalized.contains('manteiga') ||
      normalized.contains('requeijão') ||
      normalized.contains('requeijao') ||
      normalized.contains('presunto')) {
    return Icons.egg_alt_outlined;
  }

  // Mercearia Seca
  if (normalized.contains('mercearia seca') ||
      normalized.contains('arroz') ||
      normalized.contains('feijão') ||
      normalized.contains('feijao') ||
      normalized.contains('macarrão') ||
      normalized.contains('macarrao') ||
      normalized.contains('massa') ||
      normalized.contains('farinha') ||
      normalized.contains('grão') ||
      normalized.contains('grao') ||
      normalized.contains('café') ||
      normalized.contains('cafe') ||
      normalized.contains('óleo') ||
      normalized.contains('oleo') ||
      normalized.contains('azeite') ||
      normalized.contains('sal') ||
      normalized.contains('açúcar') ||
      normalized.contains('acucar') ||
      normalized.contains('tempero')) {
    return Icons.takeout_dining_outlined;
  }

  // Mercearia Líquida (Bebidas)
  if (normalized.contains('mercearia líquida') ||
      normalized.contains('mercearia liquida') ||
      normalized.contains('bebida') ||
      normalized.contains('bebidas') ||
      normalized.contains('refrigerante') ||
      normalized.contains('suco') ||
      normalized.contains('água') ||
      normalized.contains('agua') ||
      normalized.contains('cerveja') ||
      normalized.contains('vinho') ||
      normalized.contains('licor') ||
      normalized.contains('vodka') ||
      normalized.contains('energético') ||
      normalized.contains('energetico')) {
    return Icons.local_drink_outlined;
  }

  // Matinais e Doces (Biscoitos/Chocolates)
  if (normalized.contains('matinais') ||
      normalized.contains('achocolatado') ||
      normalized.contains('cereal') ||
      normalized.contains('cereais') ||
      normalized.contains('biscoito') ||
      normalized.contains('bolacha') ||
      normalized.contains('chocolate') ||
      normalized.contains('geleia') ||
      normalized.contains('mel')) {
    return Icons.cookie_outlined;
  }

  // Limpeza e Lavanderia
  if (normalized.contains('limpeza') ||
      normalized.contains('lavanderia') ||
      normalized.contains('sabão') ||
      normalized.contains('sabao') ||
      normalized.contains('detergente') ||
      normalized.contains('amaciante') ||
      normalized.contains('desinfetante') ||
      normalized.contains('esponja') ||
      normalized.contains('alvejante') ||
      normalized.contains('vassoura') ||
      normalized.contains('rodo')) {
    return Icons.cleaning_services_outlined;
  }

  // Higiene e Beleza
  if (normalized.contains('higiene') ||
      normalized.contains('beleza') ||
      normalized.contains('sabonete') ||
      normalized.contains('xampu') ||
      normalized.contains('shampoo') ||
      normalized.contains('condicionador') ||
      normalized.contains('papel higiênico') ||
      normalized.contains('papel higienico') ||
      normalized.contains('pasta de dente') ||
      normalized.contains('creme dental') ||
      normalized.contains('desodorante') ||
      normalized.contains('perfume') ||
      normalized.contains('cosméticos') ||
      normalized.contains('cosmeticos')) {
    return Icons.clean_hands_outlined;
  }

  // Utilidades Domésticas
  if (normalized.contains('utilidades') ||
      normalized.contains('domésticas') ||
      normalized.contains('domesticas') ||
      normalized.contains('panela') ||
      normalized.contains('lâmpada') ||
      normalized.contains('lampada') ||
      normalized.contains('organizador') ||
      normalized.contains('prato') ||
      normalized.contains('copo') ||
      normalized.contains('talher') ||
      normalized.contains('fósforo') ||
      normalized.contains('fosforo') ||
      normalized.contains('plástico') ||
      normalized.contains('plastico')) {
    return Icons.home_repair_service_outlined;
  }

  // Pet Shop
  if (normalized.contains('pet') ||
      normalized.contains('animal') ||
      normalized.contains('animais') ||
      normalized.contains('ração') ||
      normalized.contains('racao') ||
      normalized.contains('gato') ||
      normalized.contains('cachorro') ||
      normalized.contains('cão') ||
      normalized.contains('cao') ||
      normalized.contains('passarinho')) {
    return Icons.pets_outlined;
  }

  // Saúde e Bem-estar
  if (normalized.contains('saúde') ||
      normalized.contains('saude') ||
      normalized.contains('farmácia') ||
      normalized.contains('farmacia') ||
      normalized.contains('remédio') ||
      normalized.contains('remedio') ||
      normalized.contains('medicamento') ||
      normalized.contains('curativo') ||
      normalized.contains('vitamina')) {
    return Icons.medical_services_outlined;
  }

  // Eletrônicos
  if (normalized.contains('eletrônico') ||
      normalized.contains('eletronico') ||
      normalized.contains('eletrônicos') ||
      normalized.contains('eletronicos') ||
      normalized.contains('tecnologia') ||
      normalized.contains('pilha') ||
      normalized.contains('bateria') ||
      normalized.contains('cabo') ||
      normalized.contains('carregador')) {
    return Icons.devices_outlined;
  }

  // Vestuário e Roupas
  if (normalized.contains('roupa') ||
      normalized.contains('vestuário') ||
      normalized.contains('vestuario') ||
      normalized.contains('calçado') ||
      normalized.contains('calcado') ||
      normalized.contains('meia')) {
    return Icons.checkroom_outlined;
  }

  // Outros
  if (normalized.contains('outros') ||
      normalized.contains('diverso') ||
      normalized.contains('variado')) {
    return Icons.more_horiz_outlined;
  }

  // Default fallback
  return Icons.category_outlined;
}
