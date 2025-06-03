# Sprint 3: Manipulación de tablas
# Nivel 1
## Ejercicio 1
### Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito.
### La nueva tabla debe ser capaz de identificar de forma única cada tarjeta y establecer una relación adecuada con las otras dos tablas ("transaction" y "company").
### Después de crear la tabla será necesario que ingreses la información del documento denominado "datos_introducir_credit".
### Recuerda mostrar el diagrama y realizar una breve descripción del mismo.
-- Para crear la tabla credit_card.
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(20) NOT NULL PRIMARY KEY,
	iban VARCHAR(50), 
	pan VARCHAR(100),
	pin CHAR(4),
	cvv CHAR(3),
	expiring_date VARCHAR(50));
    
-- Para agregar la FOREIGN KEY.
ALTER TABLE transaction
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

## Ejercicio 2
### El departamento de Recursos Humanos ha identificado un error en el número de cuenta del usuario con ID CcU-2938.
### La información que debe mostrarse para este registro es: R323456312213576817699999. Recuerda mostrar que el cambio se realizó.
-- Para verificar los datos que habían asignados al id CcU-2938.
SELECT *
FROM credit_card
WHERE id = "CcU-2938";

-- Para actualizar el iban de "TR301950312213576817638661" que es erroneo, a "R323456312213576817699999" que es el correcto.
UPDATE credit_card
SET iban = "R323456312213576817699999"
WHERE id = "CcU-2938";

## Ejercicio 3
### En la tabla "transaction" ingresa un nuevo usuario con la siguiente información:
-- Para agregar el id del nuevo usuario a la tabla credit_card.
INSERT INTO credit_card (id) VALUE ("CcU-9999");

-- Para agregar el id del nuevo usuario a la tabla company.
INSERT INTO company (id) VALUE ("b-9999");

-- Para ingresar el nuevo usuario.
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", "9999", "829.999", "-117.999", "111.11", "0");

## Ejercicio 4
### Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card.
### Recuerda mostrar el cambio realizado.
-- Para hacer el DROP de la columna pan.
ALTER TABLE credit_card DROP COLUMN pan;

-- Para ver la tabla credit_card sin la columna "pan".
SELECT *
FROM credit_card;


# Nivel 2
## Ejercicio 1
### Elimina de la tabla transacción el registro con ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de datos.
-- Para eliminar el registro de la tabla transaction.
DELETE FROM transaction WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

SELECT *
FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

## Ejercicio 2
### La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas.
### Se ha solicitado crear una vista que proporcione detalles clave sobre las compañías y sus transacciones.
### Será necesaria que crees una vista llamada VistaMarketing que contenga la siguiente información:
### Nombre de la compañía. Teléfono de contacto. País de residencia. Media de compra realizado por cada compañía.
### Presenta la vista creada, ordenando los datos de mayor a menor promedio de compra.
-- Para crear la vista solicitada.
CREATE VIEW VistaMarketing AS
SELECT company_name, phone, country, AVG(amount) AS average
FROM company AS c
JOIN transaction AS t ON c.id = t.company_id
GROUP BY company_id;

-- Para mostrar la vista ordenada por promedio de compra.
SELECT *
FROM VistaMarketing
ORDER BY average DESC;

## Ejercicio 3
### Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de residencia en "Germany".
SELECT *
FROM VistaMarketing
WHERE country = "Germany";


# Nivel 3
## Ejercicio 1
### La próxima semana tendrás una nueva reunión con los gerentes de marketing.
### Un compañero de tu equipo realizó modificaciones en la base de datos, pero no recuerda cómo las realizó.
### Te pide que le ayudes a dejar los comandos ejecutados para obtener el siguiente diagrama:
-- Cargar la estructura del archivo "estructura_datos_user".
-- Cargar los datos del archivo "datos_introducir_user".
-- Modificar la tabla credit_card.
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE NULL DEFAULT NULL AFTER expiring_date,
CHANGE COLUMN pin pin VARCHAR(4) NULL DEFAULT NULL,
CHANGE COLUMN cvv cvv INT NULL DEFAULT NULL,
CHANGE COLUMN expiring_date expiring_date VARCHAR(20) NULL DEFAULT NULL;

-- Agregar la fecha actual a su columna correspondiente.
UPDATE credit_card
SET fecha_actual = CURDATE()
WHERE fecha_actual IS NULL;

-- Modificar la tabla company.
ALTER TABLE company
DROP COLUMN website;

-- Modificar tabla user.
ALTER TABLE user
CHANGE COLUMN email personal_email VARCHAR(150) NULL DEFAULT NULL,
RENAME TO  data_user;

## Ejercicio 2
### La empresa también te solicita crear una vista llamada "InformeTecnico" que contenga la siguiente información:
### ID de la transacción. Nombre del usuario/a. Apellido del usuario/a. IBAN de la tarjeta de crédito usada. Nombre de la compañía de la transacción realizada.
### Asegúrate de incluir información relevante de ambas tablas y utiliza alias para cambiar de nombre columnas según sea necesario.
### Muestra los resultados de la vista, ordena los resultados de manera descendente en función de la variable ID de transacción.
-- Para crear la vista solicitada.
CREATE VIEW InformeTecnico AS
SELECT t.id AS transaction_id, du.name, du.surname, cc.iban, c.company_name
FROM transaction AS t
JOIN data_user AS du ON du.id = t.user_id
JOIN credit_card AS cc ON cc.id = t.credit_card_id
JOIN company AS c ON c.id = t.company_id;

-- Para mostrar la vista con los resultados ordenados por el ID de transacción.
SELECT *
FROM InformeTecnico
ORDER BY transaction_id DESC;