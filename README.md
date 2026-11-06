# omarchy-menu-plus

Mejoras al menú de [Omarchy](https://omarchy.org) y a los paneles que se abren desde él. La idea es que todo se lea completo, que siempre se sepa cómo volver y que siempre se pueda volver al lugar de donde se vino.

## Qué cambia

**Menú (`menuplus.menu`)**

- **Ancho:** la ventana se ensancha hasta mostrar completo el texto de cada entrada, en vez de cortarlo.
- **Volver:** con `←` vuelves a la entrada desde la que avanzaste, no al primer elemento de la lista.
- **Filas ocultas:** si hay entradas escondidas arriba o abajo, siempre se ve media fila difuminada en ese borde.
- **Fila inferior:** indica cómo volver.
  - «`<` …[menú anterior]» en los submenús.
  - «`Esc` …Cerrar» en «Go…».
- **Listas:** las entradas que abren una lista (Transcode, Keybindings, Plugins, Timezone, Remove…) llevan `›` como los submenús, y en esa lista `←` vuelve al menú.
  - Una entrada propia se marca con `"picker": true` en `~/.config/omarchy/extensions/omarchy-menu.jsonc`.
- **Extensiones:** una entrada de la extensión que reutiliza el id de una de Omarchy cambia solo los campos que declara. Antes perdía la etiqueta y la marca ✓.
- **Interruptores:** los ajustes que se prenden y apagan se ven como un interruptor al final de la fila, que muestra su estado real (encendido en color de acento). Cambiarlo no cierra el menú y el cursor se queda en la fila.
  - Los pares de Omarchy que se turnaban («Nightlight On» / «Nightlight Off», «Window Gaps On» / «Off», Animations, Bar, Battery %, Auto-hide Dock, Touchpad, Laptop Display…) pasan a ser un solo interruptor cada uno.
  - Una entrada propia se vuelve interruptor con `"toggle": true` y un `"checked"` que diga si está encendida.
  - Las entradas donde se elige una opción entre varias (Window Corners, Workspace Layout…) siguen cerrando el menú al elegir y marcan con ✓ la actual.
- **Iconos `"icon": "layout:<modo>"`:** dibujan las teselas de los layouts (`dwindle`, `scrolling`, `floating`, `matrix`).

**Paneles con movimiento lateral:** Apps (`menuplus.dock`), Emoji (`menuplus.emojis`), Clipboard History (`menuplus.clipboard`) y Theme, Background y Unlock (`menuplus.image-picker`).

- Con `Esc` vuelven al menú desde donde se abrieron, con el cursor en esa entrada. Si llegaste escribiendo en «Go…», vuelven a «Go…».
- Muestran «`Esc` …[menú anterior]». Si se abren con un atajo de teclado, dicen «`Esc` …Cerrar» y cierran como siempre.
- La caja de Apps también muestra a medias y difuminadas las filas ocultas arriba y abajo.

**`menu-select`:** igual que `omarchy-menu-select` (una opción), pero sale con código 3 cuando el usuario aprieta `←`. Sirve para scripts de varios pasos.

```bash
choice=$(menu-select "Resolución" 4k 1080p -- --back-label Pantallas)
case $? in
  0) echo "eligió $choice" ;;
  3) echo "volver al paso anterior" ;;
  *) echo "cancelado" ;;
esac
```

## Instalar

```bash
git clone https://github.com/aonath/omarchy-menu-plus.git
cd omarchy-menu-plus
./install.sh
```

Cada plugin reemplaza al de Omarchy del que viene, como lo hace `omarchy plugin clone`. Se puede volver a ejecutar para actualizar.

## Desinstalar

```bash
./uninstall.sh
```

Vuelven los plugins originales de Omarchy.

## Notas

- Son copias modificadas de plugins de Omarchy: las mejoras que Omarchy haga a esos plugins no llegan solas. Para incorporarlas, hay que aplicar de nuevo estos cambios sobre la versión nueva.
- Los plugins copiados no reciben la biblioteca de aplicaciones del shell, así que `menuplus.dock` crea la suya.
- Combina con [omarchy-matrix](https://github.com/aonath/omarchy-matrix): con los dos instalados, Appearance › Workspace Layout usa las teselas del botón de la barra.
