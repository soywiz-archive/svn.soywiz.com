// Compilar:
// gcc.exe -O2 examples\simple.c -obin\simple.exe -Iinclude -Llib -lgamelib -lopengl32 -lSDLmain -lSDL -lSDL_net -lSDL_mixer -lSDL_ttf -lSDL_image

#include <gamelib/gamelib.h>

int main() {
	// Creamos una variable para almacenar la musica de fondo
	Music music;

	// Creamos una variable para almacenar la fuente
	Font font;

	// Creamos dos variables para almacenar las imágenes con el fondo y el logo
	Image bg, logo;

	// Creamos variables para almacenar: la posición, el tamaño, el ángulo y la transparencia del logo
	int x, y;
	float size = 1, angle = 0, alpha = 1;

	// Elegimos un título para la ventana
	VideoModeSetTitle("Simple Example");

	// Creamos una ventana de 640x480 (en ventana)
	VideoModeSet(640, 480, true);

	// Colocamos la posición del logo, en la mitadde la pantalla
	x = screenWidth / 2;
	y = screenHeight / 2;

	// Cargamos las imágenes con el fondo y el logo
	bg   = ImageLoadFromFile("res/bg.png");
	logo = ImageLoadFromFile("res/logo.png");

	// Cargamos la fuente TTF que usaremos en el juego (de tamaño 18px de alto)
	font = FontLoadFromFile("res/font.ttf", 18);

	// Definimos el punto de centrado de la imagen, en el propio centro de la imagen
	ImageSetCXY(logo, logo->w / 2, logo->h / 2);

	music = MusicLoadFromFile("res/music.s3m");

	MusicPlay(music);

	// Realizamos el bucle principal, hasta que se pulse la tecla ESCAPE
	while (!key[_esc]) {
		// Movemos la imagen con las teclas del cursor, siempre y cuando no se salga de la pantalla
		if (keyv[_left ] && x > 0           ) x -= 5;
		if (keyv[_right] && x < screenWidth ) x += 5;
		if (keyv[_up   ] && y > 0           ) y -= 5;
		if (keyv[_down ] && y < screenHeight) y += 5;

		// Cambiamos el tamaño del logo entre [-1.5, 1.5]
		if (keyv[_s] && size > -1.5) size -= 0.1;
		if (keyv[_w] && size <  1.5) size += 0.1;

		// Cambiamos el ángulo del logo
		if (keyv[_a]) angle -= 5;
		if (keyv[_d]) angle += 5;

		// Reiniciamos los valores por defecto
		if (key[_enter]) {
			angle = 0;
			alpha = size = 1;
			x = screenWidth / 2;
			y = screenHeight / 2;
		}

		// Empezamos a renderizar cosas en 2D
		VideoModeEnable2D();

		// Pintamos la imagen de fondo en las coordenadas 0, 0
		// La posición de centrado de las imágenes por defecto es la 0, 0 así que
		// la imágen se pintará con centro 0, 0 desde la esquina superior izquierda
		DrawImage(bg, 0, 0);

		// Pintamos el logo, especificando además, tamaño, ángulo y alpha
		DrawImageEx(logo, x, y, size, angle, alpha);

		// Pintamos un rectángulo semitransparente negro
		ColorSet(0.0f, 0.0f, 0.0f, 0.5f);
		DrawFilledRectangle(0 ,0, screenWidth, 90);

		// Pintamos un texto informativo de color blanco
		ColorSet(1.0f, 1.0f, 1.0f, 1.0f);
		DrawFontTextf(
			font, 6, 14,
			"Puedes mover el logo con las teclas del cursor XY(%d, %d)\n"
			"Puedes cambiar el tamaño del logo con las teclas {W, S} TAM(%1.3f)\n"
			"Puedes girar el logo con las teclas {A, D} ANG(%1.3f)\n"
			,
			x, y,
			size,
			angle
		);

		// Terminamos de renderizar cosas en 2D
		VideoModeDisable2D();

		// Producimos un frame: actualizamos el teclado, el ratón, renderizamos todos
		// los cambios en la pantalla, y borramos posteriormente la pantalla para poder
		// dibujar otra vez sobre ella.
		VideoModeFrame();
	}

	return 0;
}
