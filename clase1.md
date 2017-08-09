# Clase 15/03/2017

## Link Útiles

 - Sitio de la materia: https://sites.google.com/site/programacionhm/unq
 - Github con ejemplos de la materia https://github.com/orgs/uqbar-paco (tip: filtren por "obj3")
 - Canal de youtube: https://www.youtube.com/channel/UC20rhT1zAZyVRZuRqukk74Q/videos

## Qué vimos

 - Se repasaron brevemente conceptos vistos en materias anteriores (clases, interfaces, prototipos, polimorfismo tipado explícito, tipado implícito, etc)
 - Se comentó que la materia se enfoca principalmente en tres temas: Mixins/Traits, Metaprogramación y diseño con elementos de OOP y funcionales.
 - Se presentó un ejercicio sencillo de diseño. Como parte de la consigna, no se podían usar clases para resolverlo.
   - Hicimos una resolución en pizarrón usando únicamente objetos y delegación.
   - Hicimos otra resolución en JavaScript usando prototipos.
 - Presentamos el ejercicio "Age of Empires" y planteamos una resolución con un modelo de clases y herencia simple.
 - Discutimos las problemáticas que encontramos al diseñar la solución.
 - Se planteó la opción de usar herencia múltiple. Vimos el problema del diamante.
 - Se presentó el concepto de Mixins como una alternativa para la resolución del ejercicio anterior.
 - Vimos que los mixins ofrecen, a diferencia de la herencia múltiple, una estrategia de resolución de conflictos llamada linearización.
 - Se dió una introducción al lenguaje Ruby y cómo se utilizan los mixins. Implementamos la resolución del ejercicio anterior.

## Para la clase siguiente

 - Leer el paper de [Mixins](https://d8a0dde1-a-62cb3a1a-s-sites.googlegroups.com/site/programacionhm/conceptos/mixins/Paper%20-%20Bracha%2C%20Cook%20-%20Mixin-Based%20Inheritance.pdf?attachauth=ANoY7cqbcrZ3pmTTzR7PWq9dJQqoJERPbWgsN1HOkIl5vHo7Z8YFAS2khfzq3v-M8rHTsGGl9NT4LW87Z6evHTc_1g7oCfGw0SQG_VyjVZtyIC5utmPvI-c10Y_l2tTCfNxxkckw9OGDFJt9nARVAhUTfHSp9RulcrVxCfAncjES63FC6XTzuVtUp-DQXtKJac-fzFcpxaFApQmwFkGI2gAXF9JdZpSie6ov4LlGtDjEGcP-nkNzeHvAGo45sMNnJxncfTUK9ndQDLiSXIeWjlq-7FKr5sYK8mpfYlUKNQBI7oatfpkUHHA%3D&attredirects=0)

## Instalación del entorno Ruby

#### RubyMine
 
 - Descarga de [RubyMine](https://www.jetbrains.com/ruby/)
 - Cuenta [gratuita estudiantil de JetBrains](https://www.jetbrains.com/student/) utilizando mail de campus (pueden acceder desde el campus virtual)
 - Instalación en [Linux](https://www.youtube.com/watch?v=OyLoonEjfDY)
 - Instalación en [Windows](https://www.youtube.com/watch?v=Y0G9hScWgAs)
 
 ## Anexo
 
 ### Código javascript que escribimos en clase:

```javascript
var perro = {
  "nombre":"fido"
};

var sano = {
  "patpat":funcion(){console.log(" n___n ");}
};

var rabioso = {
  "patpat":funcion(){console.log("GRRRRRR");}
};

perro.__proto__ = sano;

perro.patpat();

perro.__proto__ = rabioso;

perro.patpat();

```

### Código ruby visto en clase para el ejercicio del Age of Empires

```ruby
class Caminador
  def caminar()
    puts "camino"
  end

  def hablar
    puts "yo camino, no me jodan"
  end
end

class Aldeano < Caminador
  def construir()
    puts "construyo"
  end
end

module Atacante
  def atacar(a_alguien)
    a_alguien.recibir_danio(poder_ofensivo)
  end

  def hablar
    puts "Hurra!"
    super
  end
end

module Defensor
  def recibir_danio(cuanto)
    danio_recibido = defender(cuanto)
    self.salud = (salud - danio_recibido)
    danio_recibido
  end

  def defender(cuanto)
    [0,cuanto - poder_defensivo].max
  end

  def hablar
    puts "Auch!"
    super
  end
end

module ConPoderOfensivo
  def poder_ofensivo
    10
  end
end

module PocionDePoder
  def poder_ofensivo
    5 + super
  end
end

module Espada
  def poder_ofensivo
    2 * super
  end
end

class Guerrero < Caminador
  include Atacante,
          Defensor,
          Espada,
          PocionDePoder,
          ConPoderOfensivo

  attr_accessor :salud, :poder_defensivo

  def initialize(defensa=0)
    @salud = 100
    @poder_defensivo = defensa
  end

end

class Berserker < Guerrero

  attr_accessor :salud_faltante

  def initialize(defensa=0)
    super
    @salud_faltante = 0
  end

  def atacar(a_quien)
    a_quien.recibir_danio(poder_ofensivo + salud_faltante)
  end

  def recibir_danio(cuanto)
    @salud_faltante += super
  end

end

class Misil
  include Atacante

  attr_accessor :poder_ofensivo

  def initialize
    @poder_ofensivo = 1000
  end
end

class Muralla
  include Defensor
  attr_accessor :salud, :poder_defensivo

  def initialize(defensa=500)
    @poder_defensivo=defensa
    @salud = 1000
  end
end

#aldeano = Aldeano.new

#aldeano.construir
#aldeano.caminar

#guerrero = Guerrero.new

#guerrero.salud = 50
#guerrero.luchar
#guerrero.caminar
#puts guerrero.salud

un_guerrero = Guerrero.new
otro_guerrero = Guerrero.new
un_guerrero.atacar(otro_guerrero)
puts "Mi salud es #{otro_guerrero.salud}"


un_guerrero = Guerrero.new
otro_guerrero = Guerrero.new(defensa = 5)
un_guerrero.atacar(otro_guerrero)
actual = otro_guerrero.salud
esperado = 95
puts "#{esperado} == #{actual}"

un_berserker = Berserker.new
mas_guerrero = Guerrero.new

mas_guerrero.atacar un_berserker
un_berserker.atacar mas_guerrero

actual = mas_guerrero.salud
esperado = 80
puts "#{esperado} == #{actual}"

un_misil = Misil.new
otro_guerrero_mas = Guerrero.new
un_misil.atacar otro_guerrero_mas

actual = otro_guerrero_mas.salud
esperado = -900
puts "#{esperado} == #{actual}"

#otro_guerrero_mas.atacar un_misil

una_muralla = Muralla.new
otro_misil = Misil.new
otro_misil.atacar una_muralla
actual = una_muralla.salud
esperado = 500
puts "#{esperado} == #{actual}"

un_guerrero.hablar
```
