
//-----------------------------------------------------------------------
// TITULO: shooter tutorial 1.0 (galax21)
// TUTORIAL PARA MUESTRA JUEGO DE NAVES
// AUTOR:  JMSanta
// FECHA:  XXXXXXXX
// ENTORNO: DIV games studio 2.
// div games studio es un entorno que facilita enormemente el empezar
// a programar juegos basicos, bastante completos.
// el entorno es de 1999. pero aun me sigue asombrando.
// puedes hacer juegos 2D tipo ROL como zelda muy completos, incluso
// soporta algunas cosas en 3D. y tiene sonidos y todo lo necesario.
//-----------------------------------------------------------------------

PROGRAM galax21_beta; // NOMBRE PROGRAMA

//CONST
// VARIABLES GLOBALES
GLOBAL  texts,enemyPoint,galaga,puntuacion,life,nivel,hyperspace,
        IdLaserEnemy, mainScroll, fichero_efectos, main_s,
        idExplosionSnd, IdExplosion2Snd, IdHypervSnd, idLaserSnd;
// VARIABLES PRIVADAS MAIN
// PRIVATE
// -- put here private variables.
// -- MAIN ---
BEGIN
    // PONER PALETA DEL TUTORIAL
    load_pal("tutorial\tutor0.fpg");
    //set resolution
    set_mode(m640x480);
    puntuacion=0; // set score to 0.
    nivel=1; // nivel 1
    life=100; // vida de la nave. (da¤os)
    load_song("mod\obli.s3m",1); // carga musica fondo
    song(0);

    // cargar fuente
    texts = load_fnt("steroid\steroid.fnt");

    // Escribe los textos de presentaci¢n
    write(0,320,5,2,"GALAX21: DIV Test code");
    write(1,0,480,6," LEVEL");
    write(0,640,480,8,"MOVER RATON Y BTN IZQ DISPARO/FLECHA ARRIBA-TURBO");
    write(1,530,0,1,"score:");
    write(1,100,480,6,"- LIFE:");

    write_int(1,640,0,2,&puntuacion);
    write_int(1,64,480,6,&nivel);
    write_int(1,164,480,6,&life);
    // SONIDOS
    idExplosionSnd=load_pcm("alien\explosio.pcm",0);
    idExplosion2Snd=load_pcm("alien\explosi8.pcm",0);
    idLaserSnd = load_pcm("blastup\faser.pcm",0);
    idLaserEnemy = load_pcm("blastup\disparo2.pcm",0);
    idHypervSnd = load_pcm("steroid\fx33.pcm",0);

    // GRAFICOS: he reusado la mayoria de gr ficos.
    // he creado algunos enemigos manualmente.
    // Carga el fichero de gr ficos del juego alien.
    fichero_efectos=load_fpg("alien\alien.fpg");
    galaga = load_fpg("galax\gbig2.fpg");  // enemigos galaga
    main_s = load_fpg("tutorial\tutor0.fpg"); // Se carga el fichero de gr ficos
    mainScroll = load_fpg("tutorial\tutor0.fpg");

    start_scroll(0, mainScroll, 002, 002, 0, 15);
    put_screen(0,2);  // Se pone el gr fico n£mero 2 como fondo de pantalla
    naveMainLoop(); // NAVE MAIN LOOP

END //-- end main game process.

// carga sonido con Id: sndId
PROCESS carga_sonido(sndId)
BEGIN
   sound(sndId,300,100);
END

//-----------------------------------------------------------------------
// LOOP principal
//-----------------------------------------------------------------------

// Todos los juegos en casi cualquier lenguage actual de medio o alto nivel
// constan de un BUCLE o LOOP principal donde se pinta cada imagen (FRAME)
// del juego. el numero de imagenes por segundo. los FPS son FRAMES segundo.

PROCESS naveMainLoop()
PRIVATE randN, descuento=0, enumber, i, Yi, cont, iters, posEnemyX, posEnemyY, idd3;
BEGIN
 LOOP
     file=main_s;
     graph=1;
     x=mouse.x;
     y=mouse.y;
     hyperspace = false;

     IF (mouse.left) // Al pulsar el bot¢n izquierdo del rat¢n se
         disparo_nave(x,y-20);  // ejecuta proceso tipo disparo
         carga_sonido(idLaserSnd);  // y ejecuta sonido laser
     END

        // if tecla escape llamamos descargamos ficheros y salimos..
        IF (key(_esc)) destructor(); BREAK; END
        // scroll se mueve hacia abajo automaticamente.
        // tener esto en cuenta y no cagarla en las explosiones y deteccion
        // de colisiones y no introducir los procesos en el SCROLL.
        // mirar metodo explosion con la l¡nea comentada donde lo indica.
        scroll.y0-=1;
        scroll.y1-=1;

        // mover scroll con flechas
        IF (key(_right))
            scroll.x0+=2;
            scroll.x1+=1;
        END
        IF (key(_left))
            scroll.x0-=2;
            scroll.x1-=1;
        END
        IF (key(_down))
           // scroll.y0-=2;
           // scroll.y1-=1;
        END
        IF (key(_up))
            // aumentamos velocidad scroll.
            scroll.y0-=2;
            scroll.y1-=1;

            // hyperturbo activado
            hyperspace = true;

            // si no salimos por arriba, entonces mover nave en Y.
            IF(mouse.y<0)
                mouse.y-=10;
            END
            // sonido al aumentar direcci¢n en Y (turbo)
            carga_sonido(idHypervSnd);
        END
        // Crea los enemigos random de momento...
          enemyPoint += enemyPoint;

          iters = 0;

          if(nivel>7)
           iters = 1;
          end;

          // num enemigos cambia dependiendo nivel.
          FOR (cont=0; cont<=iters; cont++)
           // cada nivel tiene sus enemigos
           enumber = nivel;
           if(nivel>=12)
            enumber = 1;
           end
           // si pasamos el ultimo nivel mostramos score
           if(nivel>15)
            END_GAME_SCORE("SUCCESS");
           end;
           // posicion de los enemigos
           posEnemyX = rand(50,480);
           posEnemyY = rand(y-400,y-650);

           if(nivel!=3 && nivel!=6 && nivel!=9 && nivel!=12)
            // enemigo normal
            enemigo(enemyPoint, posEnemyX , posEnemyY,rand(enumber,enumber+1), "enemy");
           else
           // JEFE
            enemigo(enemyPoint, posEnemyX,posEnemyY,1,"boss");
           end;

            // colision de MI NAVE con disparo enemigo.
            idd3=collision(TYPE disparo_enemigo);
            IF(idd3 && life==0) // si vida 0 explotamos.
                 stop_scroll(0);
                 explosion(mouse.x,mouse.y,idExplosionSnd);
                 END_GAME_SCORE("GAMEOVER");
                 signal(ID,s_kill);
                 destructor();
            END

            IF(idd3 && life>0)
              life-=10;
              explosion(mouse.x,mouse.y-10,idExplosionSnd);
            END;

          END

       FRAME; // pinta la siguente imagen del juego
 END
END
//-----------------------------------------------------------------------------
// Proceso explosion_enemigo
// Muestra una peque¤a explosi¢n
//-----------------------------------------------------------------------------

PROCESS explosion(x,y,snd);

BEGIN
    // get_real_point(pEnemy, offset x, offset y);
    // ctype=c_scroll;  // Introduce al proceso dentro del scroll
    // NO PODEMOS INTRODUCIR el PROCESO EN EL SCROLL!! sin malas POS!!
    file=fichero_efectos;
    size=60;
    graph=301;
    z=-40; // Selecciona el gr fico inicial
    carga_sonido(snd); // Suena un sonido de explosion
    WHILE (graph<=315)
        // desplazamiento automatico scroll hace que posiciones cambien.
        FRAME;
        graph=graph+1; // An¡malo
    END
END

// crea el DISPARO de la NAVE ENEMIGA.
PROCESS disparo_enemigo(x,y)
BEGIN
  file=main_s;
  graph=61;
  REPEAT
    y+=17; // se mueve hacia abajo 10 puntos
    FRAME;
  UNTIL (y>640)
END

//-----------------------------------------------------------------------
// Maneja los disparos de la nave protagonista
// Entradas: Coordenadas del gr fico
//-----------------------------------------------------------------------

PROCESS disparo_nave(x,y)
BEGIN
    file=main_s;
    graph=3;    // Se selecciona el gr fico
    REPEAT      // Bucle de repetici¢n
        y-=16;  // Se mueve hacia arriba 16 puntos
        FRAME;  // Muestra la siguiente imagen
    UNTIL (y<0) // Repite hasta que se salga por la parte superior
END

// Mostramos SCORE total si GAME OVER o juego completado.
PROCESS END_GAME_SCORE(event)
 BEGIN
 IF (event=="GAMEOVER")
     delete_text(texts);
     write(1,320,240,1,"GAME OVER");
     write(0,320,300,1,"SCORE:");
     write_int(0,390,300,1,&puntuacion);
 END
 IF (event=="SUCCESS")
     delete_text(texts);
     write(1,320,240,1,"GAME COMPLETED!!");
     write(1,320,300,1,"SCORE:");
     write_int(1,390,300,1,&puntuacion);
     destructor();
 END
END


// Pintamos cada enemigo segun tipo, posici¢n y gr fico.
PROCESS enemigo(enemyP, x,y,gr,typ);
PRIVATE
   velocidad; // velocidad enemigo
   idd=0;     // id de uso general
   incr_angulo; // giro velocidad
   angulo2;    // vel avance
   idd2=0; // id disparo nave
   idd3=0; // id disparo enemigo
   x_point=0;
   y_point=0;
   colision_times=0;
   boss_energy=9;

BEGIN
   file=galaga;
   x_point = x;
   y_point = y;


   REPEAT

    graph=gr;

    if(typ=="boss")
     angle=90;
     graph=gr+1;
     incr_angulo=0;
     velocidad = 0;
    end

    if(typ=="enemy")
     angle=angulo2=rand(0,9*pi); // creamos un angulo al azar
     incr_angulo=rand(-pi/32,pi/32); // idem con icremento del angulo.
     velocidad = rand(2,10); // velocidad random enemigo para simplificar.
    end;

    idd=collision(TYPE disparo_nave);

    IF(idd && typ=="boss" && colision_times>=150)
      puntuacion+=200;
      signal(idd,s_kill);
      explosion(idd.x, idd.y, idExplosionSnd);
    else
      colision_times+=1;
    end;

    IF(idd)
      puntuacion+=20;
      signal(idd,s_kill); // borramos el laser
      explosion(idd.x, idd.y, idExplosionSnd); // carga efecto explosion
      signal(ID,s_kill); // despues de explosion la nave desaparece.
    END

    idd2=collision(TYPE naveMainLoop);

    IF(idd2)
     stop_scroll(0);
     explosion(mouse.x, mouse.y, idExplosionSnd);
     END_GAME_SCORE("GAMEOVER");
     signal(idd2,s_kill);
     destructor();
    END

    // desplazamiento general enemigo en pantalla.
    x+= 2;
    y+= velocidad;

    // si nuestra nave tiene turbo la velocidad de objetos aumenta.
    IF(hyperspace)
        y+=6;
        x-=2;
    END

    angle=rand(0,180);

    //cambio de NIVEL cada 2000 puntos y PICO.
    IF(puntuacion > nivel * 2000 + (nivel * 1500 ) )
        nivel+= 1;
    END

    // cuando llegamos al 3 nivel, los enemigos disparan. mas dificultad.
    if(y>rand(0,100) && nivel>2 && rand(0,10000)>7700)
      disparo_enemigo(x,y); // crea el disparo del enemigo
      carga_sonido(idLaserEnemy);
    end

    FRAME; // pintar siguente IMAGEN
   // importante : las cosas se pintan hasta que salgan de la pantalla
   // para evirar memory leaks ( para AHORRAR MEMORIA RAM )
   // es un error de principiantes NO PONERLO.
   // como la resolucion es 640x480 ponemos esos numeros.
   UNTIL (x>640+16 || y>480+16 || x<-16 || y<-16)

END

// funcion donde descargamos datos, unload, stops...
// esto no es muy necesario pero queda bonito
// un destructor en otros lenguajes elimina cosas que NO USAMOS.
FUNCTION destructor()
BEGIN
    stop_song();
    unload_song(0);
    unload_pcm(0);
    unload_wav(0);
END