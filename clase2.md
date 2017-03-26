Seguimos trabajando sobre el ejercicio de la [clase pasada](clase1.md). Se agregaron los siguientes requerimientos:

### El descanso de la guerra

Todas las unidades pueden descansar. Cuando un atacante descansa, tiene el efecto de duplicar su potencial ofensivo en su próximo ataque (y luego vuelve al original). Cuando un defensor descansa, suma siempre 10 de salud.

### Banzai!

La característica del kamikaze es que se comporta como un atacante y un defensor, y su poder ofensivo es 250, pero luego de atacar, su salud queda en 0. Como la unidad va a morir luego de atacar, puede descansar como atacante, pero no debe descansar como defensor.

### Atacando de la mano

Queremos que los guerreros formen parte de un pelotón. Cuando un guerrero es atacado, el pelotón puede tomar alguna acción. Ciertos pelotones se retiran cuando alguna de sus unidades es lastimada. Otros pelotones hacen que el guerrero descanse cuando recibe un daño y no está descansado. Un guerrero está descansado cuando su salud es mayor a 40.

---

Repasando como quedó nuestro modelo la última clase, se podría simplificar a algo así:

(Verde = Mixin)

![](https://yuml.me/ba2b1507.png)


## Primer punto
Como al descansar las unidades poseen un compotamiento distinto si son Atacantes o Defensores, no cabe duda que ese comportamiento lo queríamos poner en sus respectivos mixins.

La implementación para los Defensores no debería tener inconvenientes, como al recibir daño se le resta la vida, al descansar debería sumale 10.
El comportamiento de los Atacantes tiene una dificultad extra, debería modificar su estado para tener el doble de poder, pero eso tendría que revertirse la próxima vez que ataque. Sugieron varias soluciones:
1. Agregar un booleano y poner un `if`.
2. Tener un factor de ataque, que es un número que se multipllica al poder ofensivo real. Comienza en 1, cuando descansa lo cambia a 2 y después de atacar siempre lo deja en 1 (eso podría estar en un en el mismo mixin Atacante u otro mixin).
3. Manejarlo con un [state](https://en.wikipedia.org/wiki/State_pattern).

Pero nos dimos cuenta que había un problema con el Guerrero que, al ser Atacante y Defensor, debería hacer ambas cosas y no estaba pasando: solamente se comportaba como Atacante, ya que la linealización quedó: Guerrero -> Atacante -> Defensor -> Unidad y, por ende, al encontrar el método de Atacante ejecuta y termina.

Para solucionarlo aplicamos el patrón [chain of resposibilities](https://en.wikipedia.org/wiki/Chain-of-responsibility_pattern) llamando siempre a `super` al descansar. Eso nos obligaba a tener un método que corte la cadena. Se propusieron alternativas:
1. Agregarlo en la superclase Unidad.
2. Agregarlo en un nuevo mixin "_CortaDescansar_".

![](http://yuml.me/93fbbcaf)


## Segundo punto
Los Kamikazes poseen un comportamiento similar a los Guerreros. Un primer pensamiento podría ser crear una subclase de Guerrero, pero vamos a ver que esa es una decisión adelantada. Recordemos que ahora nuestro comportamiento se encuentra en mixins y las clases solamente poseen _glue code_!

Bien, un primer problema a resolver sería el hacer que después de atacar la salud del Kamikaze quede en 0. 
1. Una primera solución podría ser sobreescribir el método _atacar_ en Kamikaze para que llame a `super` y luego quede con salud = 0.
2. Otra opción podría aprovechar que anteriormente, sea cual sea la estrategia elegida, tuvimos que hacer algo después de atacar (en nuestro caso, elegimos volver el _factor de ataque_ = 1). Entonces podríamos tener ese comportamiento en un método `post_atacar` y sobreescribir dicho método en el Kamikaze, llamando a `super`.

Ok, pero el verdadero conflicto con el Kamikaze es que, a pesar de ser Atacante y Defensor, solamente debe descansar como Atacante. Eso significa que vamos a tener que combinar los mixin de manera distinta al Guerrero, y es por eso que decidimos que Kamikaze no va a ser subclase de Guerrero, sino otra subclase de Unidad.

Para resolver el problema se puede optar por varias soluciones:
1. Si se optó por tener un mixin "_CortaDescansar_". Lo único que tendríamos que hacer que ponerlo en el medio entre Atacante y Defensor, así al descansar se corta la cadena de `super`s y no llega a Defensor. 
`include Atacante, CortaDescansar, Defensor`
2. Otra opción sería usar [alias_method](http://apidock.com/ruby/Module/alias_method) para duplicar el método `descansar` de Atacante y tener un acceso directo a dicho método desde la clase, de esa forma nos podríamos "saltear" el descansar de Defensor. 
```Ruby
class Kamikaze < Unidad
  include Atacante
  alias_method :descansar_atacante, :descansar
  include Defensor
  
  ....
  
  def descansar
    descansar_atacante
  end
end
```
Cabe destacar que cuando separamos los `include`s eso cambiar el _lookup method_. En este caso la linealización quedaría: Kamikaze -> Defensor -> Atacante -> Unidad.

![](http://yuml.me/869def96)


## Tercer punto
Por último, se pide agregar a los Pelotones. Luego de pensar un rato nos dimos cuenta que no se podía solucionar _solamente_ con mixins. Necesitamos una nueva entidad que decida cómo debe comportarse los Guerreros cuando son atacados, necesitamos un objeto Pelotón.

Como hay dos comportamientos posibles para los Pelotones, estos podrían ser dos clases o mixins distintos. Además, los Pelotones deberían ser notificados cuando un Guerrero es atacado. 
Rápidamente salió el patrón [Observer](https://en.wikipedia.org/wiki/Observer_pattern) de boca de todos. Los Pelotones son observers del método atacar de los guerreros. Para eso recordamos que los observers debían registrarse en los observados y estos guardar la referencia para notificar en el caso que pase la acción a ser observada. Decidimos poner toda esa lógica en mixins (_ObserverAtacar_ y _ObservableAtacar_) para poder reutilizarlos y no "ensuciar" las clases con dicho código.

Finalmente cada clase de Pelotón implementa lo que debe hacer cuando un Guerrero es atacado.

![](http://yuml.me/6cb76d31)

---

Bueno, esto ha sido cómo resolver el ejercicio de Age of Empires para Objetos 3, te dejamos [este código](age_of_empires_recargado.rb) con una posible solución.
Esperamos que les haya gustado.
Chau!
