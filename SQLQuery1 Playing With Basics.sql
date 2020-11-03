USE Tuesday_Exercise

SELECT * FROM planets1

INSERT INTO planets1 (PlanetName, diameter)
VALUES ('Pluto', 10);

INSERT INTO planets1 (PlanetName)
VALUES ('X');

UPDATE planets1
SET diameter = 100
WHERE PlanetName = 'Pluto';