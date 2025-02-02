# Smart List - Documentação

## Arquitetura

src/
├── core/
│ ├── firebase/ # Configurações do Firebase
│ ├── services/ # Serviços externos (APIs)
│ ├── themes/ # Configurações de tema
│ └── utils/ # Utilitários gerais
├── models/ # Modelos de dados
├── providers/ # Gerenciamento de estado
├── views/ # Telas da aplicação
└── widgets/ # Componentes reutilizáveis


## Métodos Principais

### `ContactProvider`
| Método               | Descrição                                      |
|----------------------|-----------------------------------------------|
| `initialize()`       | Inicia listener de atualizações do Firestore  |
| `addContact()`       | Adiciona novo contato com geolocalização      |
| `fetchAddress()`     | Busca endereço via CEP (ViaCEP API)           |
| `filteredContacts`   | Lista filtrada e ordenada                     |

### `AuthProvider`
| Método               | Descrição                                      |
|----------------------|-----------------------------------------------|
| `signUp()`           | Cadastro com e-mail/senha                     |
| `login()`            | Autenticação com validação                    |
| `deleteAccount()`    | Exclusão segura com reautenticação            |

### `FirestoreService`
| Método               | Descrição                                      |
|----------------------|-----------------------------------------------|
| `getContactsStream()`| Stream de contatos em tempo real              |
| `addContact()`       | Persiste contato no Firestore                 |

## Fluxo de Dados
1. **Autenticação**:  
   - Usuário faz login/cadastro via `AuthProvider`
   - Dados salvos no Firestore Authentication

2. **CRUD Contatos**:  
   - Operações acionadas via `ContactProvider`
   - Dados sincronizados em tempo real via Stream

3. **Integrações**:  
   - ViaCEP para busca de endereços
   - Google Maps API para geolocalização

## Dependências
Flutter 3.19.3
Firebase Core 2.18.0
Cloud Firestore 4.8.4
GoRouter 6.5.7
Provider 6.0.5