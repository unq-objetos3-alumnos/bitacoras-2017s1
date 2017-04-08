Nosotros estamos acostumbrados a crear programas sobre un dominio específico:
- Golondrinas que vuelan.
- Guerreros que se atacan.
- Productos que son comprados.

Pero también existen programas que tienen como dominio **otro programas**:
- Un compilador se puede pensar como un programa que genera otro programa.
- Un formateador de código es un programa que manipula otro programa.
- Una herramienta como javadoc utiliza nuestro programa para generar su documentación.

# Metaprogramación

Denominamos así al proceso o la práctica por la cual escribimos programas que generan, manipulan o utilizan otros programas.

En general la metaprogramación se utiliza más fuertemente en el desarrollo de frameworks y herramientas que ayudan en el proceso de creación de programas.
Dado que los frameworks van a resolver cierta problemática de las aplicaciones, no van a estar diseñados para ninguna en particular. Es decir, la idea de framework es que se va a poder aplicar y utilizar en diferentes dominios desconocidos para el creador del framework.

## Reflection

Es un caso particular de metaprogramación, donde **“metaprogramamos” en el mismo lenguaje** en que están escritos (o vamos a escribir) los programas. Es decir, todo desde el mismo lenguaje.

Para esto, generalmente, es necesario contar con facilidades o herramientas específicas, digamos “soporte” del lenguaje. Entonces reflection, además, abarca los siguientes items que vamos a mencionar en esta lista:

- **Introspection**: Se refiere a la capacidad de un sistema, de analizarse a sí mismo. Algo así como la introspección humana, pero en términos de programa. Para eso, el lenguaje debe proveer ciertas herramientas, que le permitan al mismo programa, “ver” o “reflejar” cada uno de sus componentes.
- **Self-Modification**: Es la capacidad de un programa de modificarse a sí mismo. Nuevamente esto requiere cierto soporte del lenguaje. Y las limitaciones van a depender de este soporte.
- **Intercession**: Es la capacidad de modificar las características del lenguaje desde el mismo. Por ejemplo: agregarle orientacin a objetos a Lisp (CLOS).

## Modelos y metamodelos
Así como todo programa construye un modelo para describir su dominio, los lenguajes pueden hacer lo mismo para describir sus abstracciones. **El domino de un metaprograma son los programas**.

El programa describe las características de los elementos del dominio utilizando clases, métodos, atributos entre otros. Entonces, el modelo puede contener por ejemplo una clase Guerrero, que modela a los guerreros en el domino.

Un metaprograma usará el metamodelo que describe al programa base. Así como en el dominio hay guerreros, los elementos del “metadominio” serán las construcciones del lenguaje, o sea, las clases, atributos, métodos, etc.

### Introspection en Ruby

#### Las clases
Para comenzar, podemos pedirle la clase a un objeto, y ésta su superclasses:
```Ruby
atila = Guerrero.new
atila.class  #=> Guerrero
atila.class.superclass  #=> Unidad
Guerrero.superclass  #=> Unidad (Los mixins NO son clases!)
Guerrero.ancestors #=> [Guerrero, Atacante, Defensor, ObservableAtacar, Unidad, ...] (Acá sí aparecen los mixins!)
```

Perooo... entonces si _a las clases le podemos mandar mensajes_ para conocer su superclase o la linealización con los mixins. También **son objetos**!?

Sí! Son objetos de la clase `Class`.
```Ruby
Guerrero.class #=> Class
```

#### Los métodos
Otra cosa que podemos hacer es decirle a un objeto que invoke un método:
```Ruby
atila.send(:poder_defensivo)  #=> 10

# con send no existen los metodos privados, la seguridad es una sensacion
class A
    private
    def metodo_privado
        'cosa privada, no te metas'
    end    
end
objeto = A.new
objeto.metodo_privado #=> NoMethodError: private method `metodo_privado' called for #<A:direccion en memoria del objeto>
objeto.send(:metodo_privado)  #=> "cosa privada, no te metas"
```

Y hasta podemos pedirle sus métodos, e incluso invocarlos:
```Ruby
atila.methods #=> [:saluda, :poder_ofensivo, :poder_ofensivo=, :poder_defensivo, ...]
metodo = atila.method :poder_defensivo #=> #<Method: Guerrero#poder_defensivo>
metodo.call #=> 10
```

Como se estarán imaginando, **los métodos también son objetos**:
```Ruby
metodo = atila.method :defender
metodo.arity  #=> 1
metodo.parameters #=> [[:req, :danio]]
metodo.owner  #=> Defensor (donde esta definido)
```

También podemos pedirle los métodos de instancia a una clase, pero esto devuelve un método que no está asociado a ningún objeto, por lo tanto no se puede invocar:
```Ruby
Guerrero.instance_methods #=> Idem a atila.methods
Guerrero.instance_methods(false) #=> [:poder_ofensivo, :poder_ofensivo=, :poder_defensivo, ...] (solo los de la clase guerrero)

metodo = Guerrero.instance_method :poder_defensivo #=> #<UnboundMethod: Guerrero#poder_defensivo>
metodo.call #=> NoMethodError
```

Pero podemos asociarlos a un objeto para invocarlos, _siempre y cuando pertenezca a la jerarquía de clases donde está definido_:
```Ruby
metodo = Guerrero.instance_method :poder_defensivo
metodo.bind(atila).call #=> 10
```

El mensaje `bind(objeto)` devuelve una instancia de _Method_, pero no tiene efecto sobre el objeto en cuestion. O sea, no afecta al método lookup.

Asi como ya estuvimos jugando con las clases, objetos y metodos, tambien podemos jugar con las variables.

```Ruby
atila.instance_variables #=> [:@salud, :@poder_ofensivo, :@poder_defensivo]
atila.instance_variable_get(:@salud)  #=> 100
atila.instance_variable_set(:@salud, 50) #=> 50
atila.instance_variable_get(:@salud)  #=> 50
atila #=> pretty print muestra el estado interno
```

### Self-Modification

#### Open classes

Nos permite definir métodos y atributos en una clase ya existente. Es una forma de self modification con azucar sintáctica para no tener que hacerlo mediante mensajes.

Los métodos que se definan con el mismo nombre que otro ya existente, serán reemplazados (es destructivo).

Para Ruby, las firmas de los métodos están definidas solo por el nombre. Un método con el mismo nombre y diferente cantidad de parametros definen el mísmo método!

```Ruby
class String
  def importante
    self + '!'
  end
end
'aprobe'.importante  #=> "aprobe!"

#Cambiar métodos
class Fixnum
  def +(x)
    123
  end
end
2+2  #=> 123
```

Otra manera de abrir las clases y definir métodos es usando en la clase el `define_method` pero este es privado y como ya vimos podemos pasarlo por arriba invocando el `send`.

```Ruby
Guerrero.send(:define_method, :saluda) {
  'Hola'
}
Guerrero.new.saluda  #=> "Hola"
```

----
Aca podemos hacer referencia a dos practicas de programacion: Duck Typing y Monkey Patching.

**Duck Typing**
> …if it walks like a duck and talks like a duck, it’s a duck, right?

Debido a que ruby es un lenguaje dinamicamente tipado, hacemos referencia a un tipo de dato por el comportamiento que tiene. 
Si tenemos un objeto que cuando hace ruido hace “cuak” y camina como un pato, probablemente lo sea, y deberia poder continuar usando este objeto como si fuera uno.

**Monkey Patching**

> …if it walks like a monkey and talks like a monkey, it’s a monkey, right? So if this monkey is not giving you the noise that you want, you’ve got to just punch that monkey until it returns what you expect.

Hace referencia a la posibilidad de practicamente modificar un tipo a gusto y piacere para que responda a nuestras necesidades y realizar otro tipo de operaciones como si fuera otro.

----

#### Singleton Class

Tambien podemos empezar a hacer algunas cosas mas locas, como agregarle comportamiento a un unico objeto

```Ruby
atila.define_singleton_method(:saluda) {
  'Hola soy Atila'
}
atila.saluda  #=> "Hola soy Atila"
Guerrero.new.saluda # NoMethodError
```


### METAMODELO

Empecemos a descubrir el modelo de clases.

Vamos a jugar un poco más con el metamodelo, ya sabemos que existe el mensaje `class` que lo entienden todos los objetos, si queremos saber la superclase de una clase tenemos el mensaje `superclass`. Podríamos pensar en base a eso quiénes le proveen comportamiento a cada uno de nuestros objetos.

Recién vimos que podemos agregar un método a un objeto en particular, y no a todas las instancias. O sea que no es un método de instancia de la clase _Guerrero_:

```Ruby
atila.methods.include? :saluda #=> true
Guerrero.instance_methods.include? :saluda #=> false
```

Pero **¿quién le provee ese comportamiento a un único objeto?**

#### Autoclases / Eigen Class

El objeto que le provee el comportamiento a un sólo objeto es la **autoclase**. En Ruby podemos obtener la autoclase de un objeto mandándole `singleton_class`.


```Ruby
atila.singleton_class #=> <Class:#<Guerrero:0x00000000b46bd0>>
```

Todos los objetos tienen una singleton class, con lo cual podemos definirle comportamiento a atila y que sea el único guerrero con ese comportamiento.

Incluyanmos un mixin a una instancia, utilizando include en la singleton class o extend:

```Ruby
module W
  def m
    123
  end
end

a = Guerrero.new
a.singleton_class.include W
a.m  #=> 123
b = Guerrero.new
b.extend W
b.m  #=>123
```

También se puede tener properties para un único objeto:

```Ruby
atila.singleton_class.send(:attr_accessor, :edad)
atila.edad = 5
atila.edad  #=> 5
Guerrero.new.edad  #=> NoMethodError
```


La forma en que agregamos el método `saluda` a atila anteriormente es similar a hacer:

```Ruby
atila.singleton_class.send(:define_method, :saluda, proc { 'Hola soy Atila' })
```

O también

```Ruby
def atila.saluda
  'Hola'.importante
end
```

De la misma forma podemos declarar métodos de clase, teniendo en cuenta que en la definición de una clase, `self` es la misma clase:

```Ruby
class Unidad
  def self.gritar
    'haaaa'
  end
end

atila.gritar  #=> NoMethodError
Unidad.gritar  #=> haaaa
```

Acá le estamos agregando el método `gritar` la singleton class de la clase _Unidad_.

Podemos ver que la clase _Guerrero_ también hereda de la clase _Unidad_:

```Ruby
Espadachin.gritar  #=>haaaa
```

Les dejamos un diagrama con el metamodelo de una solución _similar_ a lo que hicimos:
![](https://raw.githubusercontent.com/tadp-utn-frba/tadp-clases/ruby-metaprogramming/Metamodelo_de_Ruby.jpg)

------

## Colecciones

Al final de la clase, estuvimos ~~repasando~~ descubriendo la api de **colleciones** de Ruby, que les va a servir para hacer el TP. 
Puede encontrar el repo con el ejemplo que estuvimos usando [aquí](https://github.com/unq-objetos3-alumnos/ClaseColecciones).
