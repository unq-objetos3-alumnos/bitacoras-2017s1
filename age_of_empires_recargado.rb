class Unidad
  attr_accessor :salud

  def initialize
    @salud = 100
  end

  def caminar
    puts "camino"
  end

  def descansar
  end

  def retirar
    puts "Retiradaaaaa"
  end

  def descansado?
    salud > 40
  end
end

module Atacante
  def atacar(unidad)
    unidad.recibir_danio(danio)
    post_ataque
  end

  def post_ataque
    self.factor_ataque = 1
  end

  def descansar
    self.factor_ataque = 2
    super
  end

  def danio
    poder_ofensivo * factor_ataque
  end

  def caminar
    puts "camino Atacante"
    super
  end
end

module Defensor
  def recibir_danio(danio)
    danio_recibido = defender(danio)
    self.salud = (salud - danio_recibido)
    danio_recibido
  end

  def defender(danio)
    [0,danio - poder_defensivo].max
  end

  def descansar
    self.salud = salud + 10
    super
  end

  def caminar
    puts "camino Defensor"
    super
  end
end

module ObservableAtacar
  def agregar_atacar_obs(observer)
    observers.push observer
  end

  def atacar(unidad)
    super
    observers.each do |observer|
      observer.fue_atacado self
    end
  end
end


class Guerrero < Unidad
  include Atacante, Defensor, ObservableAtacar

  attr_accessor :poder_ofensivo, :poder_defensivo, :factor_ataque, :observers

  def initialize(defensa=0)
    super()
    @poder_ofensivo = 80
    @poder_defensivo = defensa
    @factor_ataque = 1
    @observers = []
  end

  def caminar
    puts "camino Guerrero"
    super
  end
end

class Kamikaze < Unidad
  include Atacante
  alias_method :descansar_atacante, :descansar
  include Defensor, ObservableAtacar

  attr_accessor :poder_defensivo, :factor_ataque, :observers

  def initialize(defensa=0)
    super()
    @poder_defensivo = defensa
    @factor_ataque = 1
    @observers = []
  end

  def poder_ofensivo
    250
  end

  def post_ataque
    @salud = 0
    super
  end

  def descansar
    descansar_atacante
  end

  def caminar
    puts "camino Kamikaze"
    super
  end
end


module ObserverAtacar
  def agregar_guerrero(guerrero)
    guerrero.agregar_atacar_obs self
  end

  def fue_atacado(guerrero)
  end
end

class PelotonCobarde
  include ObserverAtacar

  attr_accessor :guerreros

  def initialize
    @guerreros = []
  end

  def agregar_guerrero(guerrero)
    guerreros.push guerrero
    super
  end

  def fue_atacado(_)
    guerreros.each do |guerrero|
      guerrero.retirar
    end
  end
end

class PelotonDormilon
  include ObserverAtacar

  def fue_atacado(guerrero)
    if not guerrero.descansado?
      guerrero.descansar
    end
  end
end
