-- criação do banco de dados para o cenário de E-commerce
create database ecommerce;
use ecommerce;

-- criar tabela cliente base
create table clients(
	idClient int auto_increment primary key,
    Address varchar(255),
    clientType ENUM('PF', 'PJ') not null,
    active boolean default true
);    

alter table clients auto_increment=1;

-- criar tabela cliente pessoa física
create table clientsPf (
    idClientPf int primary key,
    fName varchar(45),
    minit char(3),
    lName varchar(45),
    cpf char(11) not null,
    constraint unique_cpf_client unique (cpf),
    constraint fk_client_pf foreign key (idClientPf) references clients(idClient)
);

-- criar tabela cliente pessoa jurídica
create table clientsPj (
    idClientPj int primary key,
    corporateName varchar(255) not null,
    tradeName varchar(255),
    cnpj char(14) not null,
    constraint unique_cnpj_client unique (cnpj),
    constraint fk_client_pj foreign key (idClientPj) references clients(idClient)
);


-- criar tabela produto
-- size = dimensão do produto
create table product(
	idProduct int auto_increment primary key,
    pName varchar(45) not null,
    classification_kids bool default false,
    category enum('Eletrônico','Brinquedos','Vestuário', 'Alimentos','Móveis') not null,
    avaliacao float default 0, 
    size varchar(10)
);

-- criar tabela métodos de pagamento
create table paymentMethods (
    idPaymentMethod int auto_increment primary key,
    idClient int,
    paymentType enum('cartão de crédito', 'cartão de débito', 'boleto', 'pix') not null,
    cardNumber varchar(16),
    cardHolder varchar(45),
    expirationDate date,
    active boolean default true,
    constraint fk_payment_client foreign key (idClient) references clients(idClient)
);

-- criar tabela pedido
-- trabalhar na forma de pagamento 
create table orders(
	idOrder int auto_increment primary key,
	idOrderClient int,
	orderStatus enum ('Cancelado','Confirmado', 'Em processamento')  default 'Em processamento',
	orderDescription varchar(255),
	sendValue float default 10,
	createdAt timestamp default current_timestamp,
    constraint fk_orders_client foreign key (idOrderClient) references clients(idClient)
);

-- criar tabela de pagamento do pedido
create table orderPayments (
    idOrderPay int,
    idPaymentMethod int,
    paymentValue float not null,
    paymentStatus enum('pendente', 'processando', 'aprovado', 'recusado') default 'pendente',
    primary key(idOrderPay, idPaymentMethod),
    constraint fk_orderpayment_order foreign key (idOrderPay) references orders(idOrder),
    constraint fk_orderpayment_payment foreign key (idPaymentMethod) references paymentMethods(idPaymentMethod)
);

-- criar tabela de entrega
create table delivery (
    idDelivery int auto_increment primary key,
    idOrderDelivery int,
    trackingCode varchar(45),
    status enum('aguardando coleta', 'em trânsito', 'entregue', 'devolvido') default 'aguardando coleta',
    estimateddeliverydate date,
    actualdeliverydate date,
    constraint fk_delivery_order foreign key (idOrderDelivery) references orders(idOrder)
);



-- criar tabela de estoque
create table productStorage(
	idProdStorage int auto_increment primary key,
	storageLocation varchar(255),
	quantity int default 1
);

-- criar tabela fornecedor
create table supplier(
	idSupplier int auto_increment primary key,
	socialName varchar(255) not null,
	CNPJ char(15) not null,
    address varchar(255),
	contact char(45) not null,
    constraint unique_cnpj_supplier unique (CNPJ)
);

-- criar tabela de vendedor
create table seller(
	idSeller int auto_increment primary key,
	socialName varchar(255) not null,
	CNPJ char(15),
    CPF char(11),
    address varchar(255),
	contact char(45) not null,
    constraint unique_cnpj_supplier unique (CNPJ),
	constraint unique_cpf_supplier unique (CPF),
	constraint check_seller_document check (
        (cnpj is not null and cpf is null) or
        (cnpj is null and cpf is not null)
	)

);

-- criar tabela produto_vendedor
create table productSeller(
	idPSeller int,
	idPproduct int,
    prodQuantity int default 1,
    primary key (idPSeller, idPproduct),
    constraint fk_product_seller foreign key (idPSeller) references seller(idSeller),
    constraint fk_product_product foreign key (idPproduct) references product(idProduct)
);

-- criar tabela produto_pedido

create table productOrder(
	idPOproduct int,
    idPOorder int,
    poQuantity int default 1,
    poStatus enum('Disponível', 'Sem estoque') default 'Disponível',
    primary key (idPOproduct, idPOorder),
    constraint fk_productorder_product foreign key (idPOproduct) references product(idProduct),
    constraint fk_procuctorder_order foreign key (idPOorder) references orders(idOrder)
);

-- criar tabela Produto_em_estoque
create table storageLocation(
	idLproduct int,
	idLstorage int,
	location varchar(255) not null,
	primary key (idLproduct, idLstorage),
	constraint fk_storage_location_product foreign key (idLproduct) references product(idProduct),
	constraint fk_storage_location_storage foreign key (idLstorage) references productStorage(idProdStorage)
);

-- criar tabela produto_fornecedor
create table productSupplier(
	idPsSupplier int,
	idPsProduct int,
    quantity int not null,
    constraint fk_product_supplier foreign key (idPsSupplier) references supplier(idSupplier),
    constraint fk_product_supplier_product foreign key (idPsProduct) references product(idProduct)	
);