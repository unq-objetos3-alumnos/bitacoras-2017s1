En esta clase estuvimos practicando lo visto la clase anterior haciendo las [guías de metaprogramación de Mumuki](http://obj3-unq.mumuki.io/chapters/36-metaprogramacion).

Y aprendimos el `method_missing`.

### Method Missing

Cuando le enviamos un mensaje a un objeto, se ejecuta el primero que se encuentra durante el method lookup. Si no encontrase ninguno, arroja una excepción del tipo **NoMethodError**, salvo que ese objeto tenga definido un método para el mensaje `method_missing`. 

Este mensaje recibe por parámetro el nombre del mensaje que no se encontró, junto con los argumentos con los cuales fue invocado. Esto nos permite manejar esta clase de situaciones en runtime, siendo una herramienta muy poderosa para hacer, entre otras cosas, que un objeto entienda cualquier mensaje.
