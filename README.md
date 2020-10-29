# DPN: Petri Nets con Delphi

<br/>
<div>
  <!-- Stability -->
  <a href="https://nodejs.org/api/documentation.html#documentation_stability_index">
    <img src="https://img.shields.io/badge/stability-experimental-orange.svg?style=flat-square"
      alt="API stability" />
  </a>
  <!-- Standard -->
  <a href="https://img.shields.io/badge">
    <img src="https://img.shields.io/badge/Language-Delphi-brightgreen.svg"
      alt="Delphi" />
  </a>
  <!-- Standard -->
  <a href="https://img.shields.io/badge">
    <img src="https://img.shields.io/badge/Date-2020-red.svg"
      alt="2005" />
  </a>
</div>
<br/>

## Otros frameworks utilizados

* Spring4D
* DUnitX

## Version de Delphi recomendada

10.4.1 debido a que se han resuelto problemas de las librerías parallel utilizadas aquí

## Estado

El proyecto está en sus primeros pasos

### Caracteristicas
* Evolución de tokens coloreados
* Multiples disparos de transiciones concurrentes
* Transiciones condicionadas, hay condiciones a cumplir y acciones a ejecutar en caso de que la transición se dispare

### Pendiente (mucho)
* terminar el core: multidisparo
* terminar unittesting del core
* ampliar core: logging, debugging, persistencia de configuracion
