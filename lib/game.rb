require "gosu"

class Tutorial < Gosu::Window
  def initialize
    super 640, 480, :fullscreen => true

    self.caption = "Tutorial Game"

    @background_image = Gosu::Image.new("media/Flag-Burning.png", tileable: true)
    @player = Player.new
    @player.warp(320, 240)
    @star_anim = Gosu::Image.load_tiles("media/shit.png", 48, 48)
    @stars = []
    @font = Gosu::Font.new(20)
  end

  def update
    @player.turn_left if Gosu.button_down? Gosu::KB_LEFT
    @player.turn_right if Gosu.button_down? Gosu::KB_RIGHT
    @player.accelerate if Gosu.button_down? Gosu::KB_UP
    @player.move_back if Gosu.button_down? Gosu::KB_DOWN
    @player.move
    @player.collect_stars(@stars)
    @stars.push(Star.new(@star_anim)) if rand(100) < 4 && @stars.size < 25
    @stars.each { |star| star.move_star }
    @stars.each do |star|
      @stars.delete(star) if star.y >= 480
    end
  end

  def draw
    @player.draw
    @background_image.draw(0, 0, 0)
    @background_image.draw(0, 0, ZOrder::BACKGROUND)
    @player.draw
    @stars.each { |star| star.draw }
    @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    else
      super
    end
  end
end

class Player
  attr_accessor :score
  def initialize
    @image = Gosu::Image.new("media/trump.png")
    @beep = Gosu::Sample.new("media/b8595c632accbc199a40ad619eb4-orig (1).wav")
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
  end

  def warp(x, y)
    @x = x
    @y = y
  end

  def turn_left
    @angle -= 4.5
  end

  def turn_right
    @angle += 4.5
  end

  def accelerate
    @vel_x += Gosu.offset_x(@angle, 0.5)
    @vel_y += Gosu.offset_y(@angle, 0.5)
  end

  def move_back
    @vel_x += Gosu.offset_x(@angle, -0.5)
    @vel_y += Gosu.offset_y(@angle, -0.5)
  end

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 640
    @y %= 480

    @vel_x *= 0.95
    @vel_y *= 0.95
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end

  def score
    @score
  end

  def collect_stars(stars)
    stars.reject! do |star|
      if Gosu.distance(@x, @y, star.x, star.y) < 35
        @score += 10
        @beep.play
        true
      else
        false
      end
    end
  end
end

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end

class Star
  attr_reader :x, :y

  def initialize(animation)
    @animation = animation
    @color = Gosu::Color::argb(255, 255, 255, 255)
    @color.red = 255
    @color.green = 255
    @color.blue = 255
    @x = rand * 640
    @y = rand * 480
  end

  def draw
    img = @animation[Gosu.milliseconds / 100 % @animation.size]
    img.draw(@x , @y , ZOrder::STARS, 1, 1, @color, :default)
  end

  def move_star
    @y += 1
  end

end

Tutorial.new.show
