-- Criação do banco de dados
CREATE DATABASE oficina_mecanica;
USE oficina_mecanica;

-- Criação da tabela CLIENTE
CREATE TABLE CLIENTE (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(255),
    telefone VARCHAR(20)
);

-- Criação da tabela EQUIPE
CREATE TABLE EQUIPE (
    id_equipe INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

-- Criação da tabela MECANICO
CREATE TABLE MECANICO (
    codigo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(255),
    especialidade VARCHAR(100),
    id_equipe INT,
    CONSTRAINT fk_mecanico_equipe 
        FOREIGN KEY (id_equipe) 
        REFERENCES EQUIPE(id_equipe)
);

-- Criação da tabela VEICULO
CREATE TABLE VEICULO (
    placa VARCHAR(8) PRIMARY KEY,
    modelo VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    ano INT,
    id_cliente INT,
    CONSTRAINT fk_veiculo_cliente 
        FOREIGN KEY (id_cliente) 
        REFERENCES CLIENTE(id_cliente)
);

-- Criação da tabela ORDEM_SERVICO
CREATE TABLE ORDEM_SERVICO (
    numero INT AUTO_INCREMENT PRIMARY KEY,
    data_emissao DATE NOT NULL,
    data_conclusao DATE,
    valor_total DECIMAL(10,2) DEFAULT 0,
    status ENUM('Aberta', 'Em Andamento', 'Concluída', 'Cancelada') DEFAULT 'Aberta',
    id_equipe INT,
    placa_veiculo VARCHAR(8),
    CONSTRAINT fk_os_equipe 
        FOREIGN KEY (id_equipe) 
        REFERENCES EQUIPE(id_equipe),
    CONSTRAINT fk_os_veiculo 
        FOREIGN KEY (placa_veiculo) 
        REFERENCES VEICULO(placa)
);

-- Criação da tabela SERVICO
CREATE TABLE SERVICO (
    id_servico INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    valor_mao_obra DECIMAL(10,2) NOT NULL,
    numero_os INT,
    CONSTRAINT fk_servico_os FOREIGN KEY (numero_os) REFERENCES ORDEM_SERVICO(numero)
);

-- Criação da tabela PECA
CREATE TABLE PECA (
    id_peca INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    numero_os INT,
    CONSTRAINT fk_peca_os FOREIGN KEY (numero_os) REFERENCES ORDEM_SERVICO(numero)
);

-- Índices para otimização de consultas
CREATE INDEX idx_cliente_nome ON CLIENTE(nome);
CREATE INDEX idx_veiculo_cliente ON VEICULO(id_cliente);
CREATE INDEX idx_os_equipe ON ORDEM_SERVICO(id_equipe);
CREATE INDEX idx_os_data ON ORDEM_SERVICO(data_emissao);
CREATE INDEX idx_mecanico_equipe ON MECANICO(id_equipe);

-- Trigger para atualizar o valor total da OS quando um serviço é adicionado
DELIMITER //
CREATE TRIGGER atualiza_valor_os_servico
AFTER INSERT ON SERVICO
FOR EACH ROW
BEGIN
    UPDATE ORDEM_SERVICO
    SET valor_total = valor_total + NEW.valor_mao_obra
    WHERE numero = NEW.numero_os;
END//

-- Trigger para atualizar o valor total da OS quando uma peça é adicionada
CREATE TRIGGER atualiza_valor_os_peca
AFTER INSERT ON PECA
FOR EACH ROW
BEGIN
    UPDATE ORDEM_SERVICO
    SET valor_total = valor_total + NEW.valor
    WHERE numero = NEW.numero_os;
END//
DELIMITER ;
