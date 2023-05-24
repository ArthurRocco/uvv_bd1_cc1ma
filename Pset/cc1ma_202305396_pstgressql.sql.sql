--Selecionar o usuario do postgres e criar o usuario dono do banco de dados uvv, alem do proprio banco de dados uvv
\c "host=localhost user=postgres password=computacao@raiz";

--Apagar outro banco de dados da maquina
DROP DATABASE IF EXISTS uvv;

--Apagar outro usuario da maquina
DROP USER IF EXISTS arthur_rocco;

--Excluir um schema chamado uvv e criar um novo com o mesmo nome
DROP SCHEMA IF EXISTS lojas CASCADE;

--Criar usuario/dono do BD
CREATE USER arthur_rocco 
WITH CREATEDB CREATEROLE
ENCRYPTED PASSWORD 'arthur@rocco';

--Criar um BD, que o proprietario sera "arthur_rocco"
CREATE DATABASE         uvv
OWNER =                 arthur_rocco
TEMPLATE =              template0
ENCODING =              'UTF8'
LC_COLLATE =            'pt_BR.UTF-8'
LC_CTYPE =              'pt_BR.UTF-8'
CONNECTION LIMIT =      -1;

--Comentar ao BD, sobre do que se trata o mesmo
COMMENT ON DATABASE uvv IS 'Banco de dados para tratar de informações sobre a loja UVV e suas franquias';

--Trocar de usuario (para poder mecher no BD corretamente)
\c uvv arthur_rocco;

--Criar schema lojas, cujo sera utilizado separadamente por "arthur_rocco"
CREATE SCHEMA  lojas 
AUTHORIZATION  arthur_rocco;

--Comentar sobre o schema criado
COMMENT ON SCHEMA lojas IS 'Esquema onde será organizado o banco de dados das lojas UVV';

--Mostrar qual schema esta sendo utilizado como padrao
SELECT CURRENT_SCHEMA();

--Alternar o esquema de armazenamento dos dados
SET SEARCH_PATH TO lojas;

--Excluir a tabela "lojas" (caso ela exista)
DROP TABLE IF EXISTS lojas.lojas;

--Criar tabela/entidade "loja" com dados como nome, preco, imagens da franquia, alem de limitae uma coluna como PK (primary-key) da tabela
CREATE TABLE lojas.lojas (
                loja_id NUMERIC(38) NOT NULL,
                nome VARCHAR(255) NOT NULL,
                endereco_web VARCHAR(100),
                endereco_fisico VARCHAR(512),
                latitude NUMERIC,
                longitude NUMERIC,
                logo BYTEA,
                logo_mime_type VARCHAR(512),
                logo_arquivo VARCHAR(512),
                logo_charset VARCHAR(512),
                logo_ultima_atualizacao DATE,
                CONSTRAINT loja_id PRIMARY KEY (loja_id)
);

--Explicar o que ha na tabela "loja" por meio de um comentario
COMMENT ON TABLE lojas.lojas IS 'Informações sobre cada loja da franquia de lojas uvv.';

--Explicar o que ha nas colunas da tabela "loja" por meio de um comentario
COMMENT ON COLUMN lojas.lojas.loja_id IS 'Identifica cada loja da franquia por um único número.';
COMMENT ON COLUMN lojas.lojas.nome IS 'Exibe o nome específico de cada loja da franquia.';
COMMENT ON COLUMN lojas.lojas.endereco_web IS 'Identifica o endereço do site de cada loja';
COMMENT ON COLUMN lojas.lojas.endereco_fisico IS 'Identifica o endereco fisico de qualquer loja';
COMMENT ON COLUMN lojas.lojas.latitude IS 'Mostra a latitude da loja.';
COMMENT ON COLUMN lojas.lojas.longitude IS 'Mostra a longitude da loja.';
COMMENT ON COLUMN lojas.lojas.logo IS 'Mostra a informação binária para gerar a imagem da logo da loja no site web.';
COMMENT ON COLUMN lojas.lojas.logo_mime_type IS 'Mostra em qual formato o logo da loja está.';
COMMENT ON COLUMN lojas.lojas.logo_arquivo IS 'Identifica o nome do arquivo do logo das lojas separadamente.';
COMMENT ON COLUMN lojas.lojas.logo_charset IS 'Identifica o conjunto de caracteres usado para codificar o logo da loja.';---------------------------------------------------------------------------------------------------------------------------------
COMMENT ON COLUMN lojas.lojas.logo_ultima_atualizacao IS 'Mostra a data em que houve a última alteração na logo da loja.';

--Restringir no minimo uma coluna de endereco fisico ou web, poder ser prenchida em uma insercao de daods 
ALTER TABLE lojas.lojas
ADD CONSTRAINT verficacao_endereco CHECK (
  (endereco_web IS NOT NULL AND endereco_web != '') OR
  (endereco_fisico IS NOT NULL AND endereco_fisico != '')
);

--Criar restricao longitudinal na coluna para valores validos apenas entre -180 e 180
ALTER TABLE lojas.lojas
ADD CONSTRAINT validacao_longitude CHECK (longitude >= -180 AND longitude <= 180);

--Criar restricao latitudinal na coluna para valores validos apenas entre -90 e 90
ALTER TABLE lojas.lojas
ADD CONSTRAINT validacao_latitude CHECK (latitude >= -90 AND latitude <= 90);

--Criar restricao na coluna "logo_ultima_atualizacao" para valores validos de datas maiores ou iguais que 01/01/2020
ALTER TABLE lojas.lojas
ADD CONSTRAINT validacao_data_logo_ultima_atualizacao CHECK (logo_ultima_atualizacao >= TO_DATE('01-01-2020', 'DD-MM-YYYY'));

-- Excluir tabela "lojas.produtos" caso ja exista
DROP TABLE IF EXISTS lojas.produtos;

--Criar tabela "produto" com informacoes como produtos vendido, alem de criar uma restircao necessaria para a coluna "produto_id" seja a PK desta tabela
CREATE TABLE lojas.produtos (
                produto_id NUMERIC(38) NOT NULL,
                nome VARCHAR(255) NOT NULL,
                preco_unitario NUMERIC(10,2),
                detalhes BYTEA,
                imagem BYTEA,
                imagem_mime_type VARCHAR(512),
                imagem_arquivo VARCHAR(512),
                imagem_charset VARCHAR(512),
                imagem_ultima_atualizacao DATE,
                CONSTRAINT produto_id PRIMARY KEY (produto_id)
);

-- Comentar sobre as informacoes contidas na tabela
COMMENT ON TABLE lojas.produtos IS 'Mostra informações dos produtos vendidos nas lojas.';

--Comentar sobre as colunas da tabela "produto", explicando as suas colunas
COMMENT ON COLUMN lojas.produtos.produto_id IS 'Identifica o identificador exclusivo de cada tipo de produto.';
COMMENT ON COLUMN lojas.produtos.nome IS 'Mostra o nome do produto.';
COMMENT ON COLUMN lojas.produtos.preco_unitario IS 'Mostra por qual preço é vendido uma unidade do produto.';
COMMENT ON COLUMN lojas.produtos.detalhes IS 'Mostra alguns detalhes necessários sobre o produto.';
COMMENT ON COLUMN lojas.produtos.imagem IS 'Mostra uma sequência binária para gerar uma imagem do produto.';
COMMENT ON COLUMN lojas.produtos.imagem_mime_type IS 'Identifica o tipo de formato/extensão que a imagem do produto possui.';
COMMENT ON COLUMN lojas.produtos.imagem_arquivo IS 'Mostra o nome do arquivo da imagem do produto.';
COMMENT ON COLUMN lojas.produtos.imagem_charset IS 'Mostra o conjunto de caracteres usado para codificar a imagem do produto.';
COMMENT ON COLUMN lojas.produtos.imagem_ultima_atualizacao IS 'Mostra a data da última modificação feita na imagem do produto.';

--Restringir a coluna "preco_unitario" a nao aceitar valores negativos
ALTER TABLE lojas.produtos
ADD CONSTRAINT validacao_preco_unitario_positivo CHECK (preco_unitario >= 0);

--Restringir a coluna "imagem_ultima_atualizacao" para que a data minima seja 01/01/2020
ALTER TABLE lojas.produtos
ADD CONSTRAINT validacao_data_imagem_ultima_atualizacao CHECK (imagem_ultima_atualizacao >= TO_DATE('01-01-2020', 'DD-MM-YYYY'));

--Excluir a tabela "clientes" caso ja exista
DROP TABLE IF EXISTS lojas.clientes;

-- Criar a tabela "clientes" com informacoes sobre os clientes como id dos mesmos, e restringir "cliente_id" como PK da tabela
CREATE TABLE lojas.clientes (
                cliente_id NUMERIC(38) NOT NULL,
                email VARCHAR(255) NOT NULL,
                nome VARCHAR(255) NOT NULL,
                telefone1 VARCHAR(20),
                telefone2 VARCHAR(20),
                telefone3 VARCHAR(20),
                CONSTRAINT cliente_id PRIMARY KEY (cliente_id)
);

--Comentar o que tem na tabela "clientes"
COMMENT ON TABLE lojas.clientes IS 'Mostra informações de todos os clientes da loja.';

--Adicionar um comentario explicando o que tem nas colunas da tabela "clientes"
COMMENT ON COLUMN lojas.clientes.cliente_id IS 'Mostra o identificador único de cada cliente.';
COMMENT ON COLUMN lojas.clientes.email IS 'Mostra qual o email cadastrado pelo cliente para contato.';
COMMENT ON COLUMN lojas.clientes.nome IS 'Mostra qual o nome completo do cliente.';
COMMENT ON COLUMN lojas.clientes.telefone1 IS 'Mostra o primeiro telefone cadastrado pelo cliente para contato.';
COMMENT ON COLUMN lojas.clientes.telefone2 IS 'Mostra o segundo telefone cadastrado pelo cliente para contato.';
COMMENT ON COLUMN lojas.clientes.telefone3 IS 'Mostra o terceiro telefone cadastrado pelo cliente para contato.';

--Restringir a coluna "email" para que contenha obrigatoriamente o "@"
ALTER TABLE lojas.clientes
ADD CONSTRAINT verificacao_formato_email CHECK (email LIKE '%@%');

--Restringir as colunas "telefone1", "telefone2", "telefone3" para que nao tenha os caracteres "-", "(", ")" 

-- Restrição para "telefone1"
ALTER TABLE lojas.clientes
ADD CONSTRAINT formato_telefone1 CHECK (telefone1 NOT LIKE '%-%' AND telefone1 NOT LIKE '%(%' AND telefone1 NOT LIKE '%)%');

-- Restrição para "telefone2"
ALTER TABLE lojas.clientes
ADD CONSTRAINT formato_telefone2 CHECK (telefone2 NOT LIKE '%-%' AND telefone2 NOT LIKE '%(%' AND telefone2 NOT LIKE '%)%');

-- Restrição para "telefone3"
ALTER TABLE lojas.clientes
ADD CONSTRAINT formato_telefone3 CHECK (telefone3 NOT LIKE '%-%' AND telefone3 NOT LIKE '%(%' AND telefone3 NOT LIKE '%)%');


--Exluir a tabela "estoques" caso ja exista
DROP TABLE IF EXISTS lojas.estoques;

--Criar tabela "estoques" com informacoes do estoque como id da loja e dos produtos, e adicionar a coluna "estoque" como PK da tabela
CREATE TABLE lojas.estoques (
                estoque_id NUMERIC(38) NOT NULL,
                quantidade NUMERIC(38) NOT NULL,
                loja_id NUMERIC(38) NOT NULL,
                produto_id NUMERIC(38) NOT NULL,
                CONSTRAINT estoque_id PRIMARY KEY (estoque_id)
);

--Explicar o que ha na tabela "estoques" por meio de um comentario
COMMENT ON TABLE lojas.estoques IS 'Mostra o controle de estoque das lojas UVV.';

--Explicar os tipos de informacoes de cada coluna da tabela "estoques" por meio de um comentario
COMMENT ON COLUMN lojas.estoques.estoque_id IS 'Mostra o identificador primário de cada estoque.';
COMMENT ON COLUMN lojas.estoques.quantidade IS 'Mostra a quantidade de produtos no estoque.';
COMMENT ON COLUMN lojas.estoques.loja_id IS 'Identifica cada loja da franquia por um número único de até 38 dígitos.';
COMMENT ON COLUMN lojas.estoques.produto_id IS 'Identifica o identificador exclusivo de cada tipo de produto.';

--Criar restricao para que seja negado valoeres negativos
ALTER TABLE lojas.estoques
ADD CONSTRAINT verificacao_quantidade_positivo CHECK (quantidade >= 0);


--Relacionar as teblas "produtos" e "estoques" (No caso a tabela pai é "produtos" e a filha a tabela "estoque")
ALTER TABLE lojas.estoques ADD CONSTRAINT produto_estoques_fk
FOREIGN KEY (produto_id)
REFERENCES lojas.produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--Relacionar as tabelas "lojas" e "estoques" (No caso a tabela pai é "lojas" e a filha a tabela "estoque" )
ALTER TABLE lojas.estoques ADD CONSTRAINT loja_estoques_fk
FOREIGN KEY (loja_id)
REFERENCES lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--Excluir a tabela "envios" caso ja exista 

DROP TABLE IF EXISTS lojas.envios;

--Criar tabela "envios" com informacoes como id do envio e da loja, alem de adicionar a coluna "envio_id" como PK da tabela
CREATE TABLE lojas.envios (
                envio_id NUMERIC(38) NOT NULL,
                cliente_id NUMERIC(38) NOT NULL,
                loja_id NUMERIC(38) NOT NULL,
                endereco_entrega VARCHAR(512) NOT NULL,
                status VARCHAR(15) NOT NULL,
                CONSTRAINT envio_id PRIMARY KEY (envio_id)
);

--Exibir o que ha na tabela "envios" por meio de um comentario
COMMENT ON TABLE lojas.envios IS 'Mostra informações para o processo de envios do produto.';

--Explicar quais os tipos de informacoes de cada coluna da tabela "envios" por meio de comentarios
COMMENT ON COLUMN lojas.envios.envio_id IS 'Mostra o identificador único de cada envio.';
COMMENT ON COLUMN lojas.envios.cliente_id IS 'Mostra o identificador único de cada cliente.';
COMMENT ON COLUMN lojas.envios.loja_id IS 'Identifica cada loja da franquia por um número único de até 38 dígitos.';
COMMENT ON COLUMN lojas.envios.endereco_entrega IS 'Mostra para qual endereço o pedido do cliente está sendo levado.';
COMMENT ON COLUMN lojas.envios.status IS 'Mostra qual é o estado do produto no processo de entrega.';

--Restringir as opcoes de status da tabela "envios"
ALTER TABLE lojas.envios 
ADD CONSTRAINT check_status CHECK (status IN ('CANCELADO', 'COMPLETO', 'ABERTO', 'PAGO', 'REEMBOLSADO', 'ENVIADO'));

--Criar um relacionamento entre as tabelas "clientes" e "envios", no qual a tabela pai é "clientes" e a filha é "envios"
ALTER TABLE lojas.envios ADD CONSTRAINT clientes_envio_fk
FOREIGN KEY (cliente_id)
REFERENCES lojas.clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--Criar um relacionamento entre as tabelas "lojas" e "envios", no qual a tabela pai é "lojas" e a filha é "envios"
ALTER TABLE lojas.envios ADD CONSTRAINT loja_envio_fk
FOREIGN KEY (loja_id)
REFERENCES lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--Deletar a tabela "pedidos" caso ja exista
DROP TABLE IF EXISTS lojas.pedidos;

--Criar tabela "pedidos" com informacoes como id do pedido, data e hora, alem de adicionar a colina "pedido_id" como PK da tabela 
CREATE TABLE lojas.pedidos (
                pedido_id NUMERIC(38) NOT NULL,
                data_hora TIMESTAMP NOT NULL,
                status VARCHAR(15) NOT NULL,
                cliente_id NUMERIC(38) NOT NULL,
                loja_id NUMERIC(38) NOT NULL,
                CONSTRAINT pedido_id PRIMARY KEY (pedido_id)
);

--Restringir as opcoes do status da tabela "pedidos"
ALTER TABLE lojas.pedidos
ADD CONSTRAINT valicacao_status_pedidos CHECK (status IN ('CANCELADO', 'COMPLETO', 'ABERTO', 'PAGO', 'REEMBOLSADO', 'ENVIADO'));

--Restringir o formato da data e hora da tabela "pedidos"
ALTER TABLE lojas.pedidos
ADD CONSTRAINT check_data_hora_format CHECK (TO_CHAR(data_hora, 'DD-MM-YYYY') = TO_CHAR(data_hora, 'DD-MM-YYYY'));

--Explicar o que ha na tabela "pedidos" por meio de um comentario 
COMMENT ON TABLE lojas.pedidos IS 'Mostra informações sobre os pedidos feitas em cada loja.';

--Explicar o que ha em cada coluna na tabela "pedidos" por meio de um comentario 
COMMENT ON COLUMN lojas.pedidos.pedido_id IS 'Mostra o identificador único de cada pedido feito na loja.';
COMMENT ON COLUMN lojas.pedidos.data_hora IS 'Identifica em que dia e hora o clientes fez o pedido do produto.';
COMMENT ON COLUMN lojas.pedidos.status IS 'Mostra se o produto está no estado de produção, envios ou se já foi entregue ao cliente.';
COMMENT ON COLUMN lojas.pedidos.cliente_id IS 'Mostra o identificador único de cada cliente.';
COMMENT ON COLUMN lojas.pedidos.loja_id IS 'Identifica cada loja da franquia por um número único.';

--Relacionar as tabelas "clientes" e "pedidos", no qual a tabela "clientes" é a pai e a filha é a tabela "pedidos"
ALTER TABLE lojas.pedidos ADD CONSTRAINT clientes_pedidos_fk
FOREIGN KEY (cliente_id)
REFERENCES lojas.clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--Relacionar as tabelas "lojas" e "pedidos", no qual a tabela "lojas" é a pai e a filha é a tabela "pedidos"
ALTER TABLE lojas.pedidos ADD CONSTRAINT loja_pedidos_fk
FOREIGN KEY (loja_id)
REFERENCES lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--Excluir a tabela "pedidos_itens" caso ja exista
DROP TABLE IF EXISTS lojas.pedidos_itens;

--Criar tabela "pedidos_itens", com informacoes importantes como id dos produtos e dos pedidos
CREATE TABLE lojas.pedidos_itens (
                produto_id NUMERIC(38) NOT NULL,
                pedido_id NUMERIC(38) NOT NULL,
                numero_da_linha NUMERIC(38) NOT NULL,
                preco_unitario NUMERIC(10,2) NOT NULL,
                quantidade NUMERIC(38) NOT NULL,
                envio_id NUMERIC(38) NOT NULL,
                CONSTRAINT fk_pedido_id__fk_produto_id PRIMARY KEY (produto_id, pedido_id)
);

--Explicar as informacoes da tabela por meio de um comentario 
COMMENT ON TABLE lojas.pedidos_itens IS 'Mostra quais produtos foram requistidos por cada ordem de pedido.';

--Explicar as informacoes de cada coluna da tabela por meio de comentarios
COMMENT ON COLUMN lojas.pedidos_itens.produto_id IS 'Identifica o identificador exclusivo de cada tipo de produto.';
COMMENT ON COLUMN lojas.pedidos_itens.pedido_id IS 'Mostra o identificador único de cada pedido feito na loja.';
COMMENT ON COLUMN lojas.pedidos_itens.numero_da_linha IS 'Mostra qual o número de linha específico do produto da loja UVV que o cliente pediu.';
COMMENT ON COLUMN lojas.pedidos_itens.preco_unitario IS 'Mostra o preço pago pelo cliente ao comprar cada unidade dos produtos na ordem';
COMMENT ON COLUMN lojas.pedidos_itens.quantidade IS 'Mostra a quantidade de unidades pedida pelo cliente em sua ordem';
COMMENT ON COLUMN lojas.pedidos_itens.envio_id IS 'Mostra o identificador único de cada envios';

--Restringir a nao ter/aceitar valores negativos na coluna "preco_unitario"
ALTER TABLE lojas.pedidos_itens
ADD CONSTRAINT validacao_preco_unitario_positivo CHECK (preco_unitario >= 0);

--Restringir a nao ter/aceitar valores negativos na coluna "quantidade"
ALTER TABLE lojas.pedidos_itens
ADD CONSTRAINT validacao_quantidade_positiva CHECK (quantidade >= 0);

--Relacionar as tabelas "produtos" e "pedidos_itens", sendo que a tabela pai é "produtos" sendo a filha "pedidos_itens"
ALTER TABLE lojas.pedidos_itens ADD CONSTRAINT produto_pedidos_itens_fk
FOREIGN KEY (produto_id)
REFERENCES lojas.produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--Relacionar as tabelas "envios" e "pedidos_itens", sendo que a tabela pai é "envios" sendo a filha "pedidos_itens"
ALTER TABLE lojas.pedidos_itens ADD CONSTRAINT pedidos_pedidos_itens_fk
FOREIGN KEY (pedido_id)
REFERENCES lojas.pedidos (pedido_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--Relacionar as tabelas "pedidos" e "pedidos_itens", sendo que a tabela pai é "pedidos" sendo a filha "pedidos_itens"

ALTER TABLE lojas.pedidos_itens ADD CONSTRAINT envios_pedidos_itens_fk
FOREIGN KEY (envio_id)
REFERENCES lojas.envios (envio_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;