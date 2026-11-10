# LeafEat Mobile

Aplicativo Flutter do LeafEat para visitantes, clientes e restaurantes.

## Executar com a API local

Inicie primeiro o backend em `http://localhost:5000`. Depois, no diretório deste projeto:

```powershell
flutter pub get
flutter run -d chrome --web-port 5173
```

O endereço padrão da API é `http://localhost:5000`. Para usar outro endereço:

```powershell
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://SEU_ENDERECO:5000
```

No emulador Android, o computador normalmente é acessado por `http://10.0.2.2:5000`. Em um celular físico, use o IP do notebook na rede local e configure a API para escutar nesse endereço.

## Integração atual

- cadastro e login de cliente e restaurante;
- sessão JWT persistida localmente;
- consulta pública de estabelecimentos, pratos e informações nutricionais;
- cadastro de pratos pelo restaurante autenticado;
- mocks preservados como fallback quando a API estiver indisponível.

QR Code, mapa real e auditoria não fazem parte desta etapa.
