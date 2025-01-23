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


-- Inserção de dados para testes
-- Inserindo Clientes
INSERT INTO CLIENTE (nome, endereco, telefone) VALUES
('João Silva', 'Rua A, 123', '(11) 98765-4321'),
('Maria Santos', 'Av B, 456', '(11) 91234-5678'),
('Pedro Oliveira', 'Rua C, 789', '(11) 94567-8901'),
('Ana Pereira', 'Av D, 321', '(11) 93216-5498'),
('Carlos Souza', 'Rua E, 654', '(11) 97894-5612');

-- Inserindo Equipes
INSERT INTO EQUIPE (nome) VALUES
('Equipe Motor'),
('Equipe Elétrica'),
('Equipe Funilaria'),
('Equipe Suspensão');

-- Inserindo Mecânicos
INSERT INTO MECANICO (nome, endereco, especialidade, id_equipe) VALUES
('José Mecânico', 'Rua X, 100', 'Motor', 1),
('Paulo Eletricista', 'Rua Y, 200', 'Elétrica', 2),
('Antonio Funileiro', 'Rua Z, 300', 'Funilaria', 3),
('Roberto Mecânico', 'Rua W, 400', 'Suspensão', 4),
('Miguel Mecânico', 'Rua V, 500', 'Motor', 1),
('Ricardo Eletricista', 'Rua U, 600', 'Elétrica', 2);

-- Inserindo Veículos
INSERT INTO VEICULO (placa, modelo, marca, ano, id_cliente) VALUES
('ABC1234', 'Gol', 'Volkswagen', 2018, 1),
('DEF5678', 'Civic', 'Honda', 2020, 2),
('GHI9012', 'Corolla', 'Toyota', 2019, 3),
('JKL3456', 'Onix', 'Chevrolet', 2021, 4),
('MNO7890', 'HB20', 'Hyundai', 2017, 5),
('PQR1234', 'Kicks', 'Nissan', 2022, 1);

-- Inserindo Ordens de Serviço
INSERT INTO ORDEM_SERVICO (data_emissao, data_conclusao, status, id_equipe, placa_veiculo) VALUES
('2024-01-10', '2024-01-12', 'Concluída', 1, 'ABC1234'),
('2024-01-15', NULL, 'Em Andamento', 2, 'DEF5678'),
('2024-01-20', '2024-01-22', 'Concluída', 3, 'GHI9012'),
('2024-01-25', NULL, 'Aberta', 4, 'JKL3456'),
('2024-01-30', NULL, 'Em Andamento', 1, 'MNO7890');

-- Inserindo Serviços
INSERT INTO SERVICO (descricao, valor_mao_obra, numero_os) VALUES
('Troca de óleo', 100.00, 1),
('Revisão elétrica', 250.00, 2),
('Funilaria porta', 800.00, 3),
('Alinhamento', 150.00, 4),
('Troca de correia', 300.00, 5),
('Balanceamento', 80.00, 4),
('Troca de bateria', 50.00, 2);

-- Inserindo Peças
INSERT INTO PECA (descricao, valor, numero_os) VALUES
('Óleo Motor 5W30', 150.00, 1),
('Bateria 60Ah', 450.00, 2),
('Porta Lateral', 1200.00, 3),
('Conjunto Pastilhas', 180.00, 4),
('Kit Correia Dentada', 350.00, 5),
('Filtro de Óleo', 50.00, 1),
('Terminal Bateria', 25.00, 2);

-- Queries de Consulta

-- 1. Recuperação simples: Listar todos os mecânicos e suas especialidades
SELECT nome, especialidade
FROM MECANICO
ORDER BY nome;

-- 2. Filtro: Encontrar todas as ordens de serviço em andamento
SELECT os.numero, v.placa, c.nome as cliente, os.data_emissao
FROM ORDEM_SERVICO os
JOIN VEICULO v ON os.placa_veiculo = v.placa
JOIN CLIENTE c ON v.id_cliente = c.id_cliente
WHERE os.status = 'Em Andamento';

-- 3. Atributo derivado: Calcular o valor total de cada OS (peças + serviços)
SELECT 
    os.numero,
    os.data_emissao,
    SUM(s.valor_mao_obra) as total_servicos,
    SUM(p.valor) as total_pecas,
    SUM(s.valor_mao_obra) + SUM(p.valor) as valor_total
FROM ORDEM_SERVICO os
LEFT JOIN SERVICO s ON os.numero = s.numero_os
LEFT JOIN PECA p ON os.numero = p.numero_os
GROUP BY os.numero, os.data_emissao;

-- 4. Ordenação: Ranking de equipes por número de OS concluídas
SELECT 
    e.nome as equipe,
    COUNT(os.numero) as total_os,
    AVG(os.valor_total) as media_valor
FROM EQUIPE e
LEFT JOIN ORDEM_SERVICO os ON e.id_equipe = os.id_equipe
WHERE os.status = 'Concluída'
GROUP BY e.nome
ORDER BY total_os DESC, media_valor DESC;

-- 5. Having: Encontrar clientes com mais de um veículo e total gasto acima de 1000
SELECT 
    c.nome,
    COUNT(DISTINCT v.placa) as total_veiculos,
    SUM(os.valor_total) as total_gasto
FROM CLIENTE c
JOIN VEICULO v ON c.id_cliente = v.id_cliente
JOIN ORDEM_SERVICO os ON v.placa = os.placa_veiculo
GROUP BY c.nome
HAVING total_veiculos > 1 AND total_gasto > 1000;

-- 6. Junções complexas: Relatório completo de OS
SELECT 
    os.numero as numero_os,
    c.nome as cliente,
    v.placa,
    v.modelo,
    e.nome as equipe,
    GROUP_CONCAT(DISTINCT m.nome) as mecanicos,
    GROUP_CONCAT(DISTINCT s.descricao) as servicos,
    GROUP_CONCAT(DISTINCT p.descricao) as pecas,
    os.status,
    os.data_emissao,
    os.data_conclusao,
    os.valor_total
FROM ORDEM_SERVICO os
JOIN VEICULO v ON os.placa_veiculo = v.placa
JOIN CLIENTE c ON v.id_cliente = c.id_cliente
JOIN EQUIPE e ON os.id_equipe = e.id_equipe
JOIN MECANICO m ON m.id_equipe = e.id_equipe
LEFT JOIN SERVICO s ON os.numero = s.numero_os
LEFT JOIN PECA p ON os.numero = p.numero_os
GROUP BY os.numero, c.nome, v.placa, v.modelo, e.nome, os.status, 
         os.data_emissao, os.data_conclusao, os.valor_total;