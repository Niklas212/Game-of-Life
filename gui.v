module main

import ui
import gg
import gx
import time

const (
	col		=10
	row		=20
	//simulations per second
	sps		=4
	margin_left	= 8
	margin_top_to_grid=40
	padding		=4
	grid_padding	=12
	dead		=gx.white
	life		=gx.black
	bg_win		=gx.rgb(200, 200, 200)
	bg_grid		=gx.rgb(120, 120, 120)
	win_width  = 700
	win_height = 400
	btn_txt_cfg = gx.TextCfg{
		align : .center
		vertical_align: .middle
	}
	highlight_color = gx.red
	
)

struct Menu {
	mut:
	visible bool
	// in grid
	x	int
	y	int
	// absolute
	//pos_x	int
	//pos_y	int
	max_size	f32 = 0.5
	//width / height
	ratio	f32 = 1.5
	width	f32
	height	f32
	orientation_x	int = 0 // o: to right, 1: to left
	orientation_y	int = 0 // 0: to bottom, 1: to top
}

struct App {
mut:
	window &ui.Window = 0
	start	bool = false
	size	int =30
	margin_top int
	margin_left int
	mouse_drag	bool
	mouse_down	bool
	drag_state	bool
	menu	Menu
	window_width	int	= win_width
	window_height	int	= win_height
	btn_nm		&ui.Button = 0
	btn_start	&ui.Button = 0
	btn_size		&ui.Button = 0
	
	map	Map={
		pattern:create_map(row, col)
		width:row
		height:col
	}
}

fn main() {
	
	mut app := &App{}

	fn_mouse_down:= fn (e ui.MouseEvent, mut window &ui.Window) {
		mouse_down(mut window.state, e)
	}
	
	fn_mouse_up:= fn (e ui.MouseEvent, mut window &ui.Window) {
		mouse_up(mut window.state)
	}
	
	fn_mouse_move:= fn (e ui.MouseMoveEvent, mut window &ui.Window) {
		mouse_move(mut window.state, int(e.x), int(e.y))
	}
	
	fn_resize:= fn (w int, h int, mut window &ui.Window) {
		handle_size(mut window.state, w, h)
	}


	app.btn_nm = ui.button({
		width: 80
		height: 30
		text: "new map"
		onclick:new_map
		text_cfg: btn_txt_cfg
	})
	
	app.btn_start = ui.button({
		width: 80
		height: 30
		text: "start"
		onclick:start_stop
		text_cfg: btn_txt_cfg
				})
	
	app.btn_size = ui.button({
		width:100
		height: 30
		text: "size: 30"
		onclick:click_change_size
		text_cfg: btn_txt_cfg
				})
	
	window := ui.window({
		width: win_width
		height: win_height
		bg_color:bg_win
		title: 'GAME OF LIFE'
		resizable: true
		on_mouse_down: fn_mouse_down
		on_mouse_up: fn_mouse_up
		on_mouse_move: fn_mouse_move
		on_resize: fn_resize
		on_key_down: shortcut
		state: app
	}, [
		ui.canvas({
				width  	:400
				height  :250
				draw_fn:draw_c
			}),
			app.btn_start,
			app.btn_size,
			app.btn_nm,	
	])
	
	app.btn_size.y = 4
	app.btn_start.y = 4
	app.btn_start.x = margin_left
	app.btn_nm.y = 4
	
	
	app.window = window
	
	go app.run()
	handle_size(mut app, win_width, win_height)
	ui.run(app.window)
}

fn shortcut (e ui.KeyEvent, mut app App) {
	match int(e.key) {
		32 {start_stop(mut app, mut app.btn_start)}
		262, 263, 264, 265 {click_change_size(mut app, mut app.btn_size)}
		else {}
	}
}

fn new_map (mut app &App, mut btn &ui.Button) {
	app.map.pattern=create_map(app.map.width, app.map.height)
}

fn click_change_size (mut app &App, mut btn &ui.Button) {
	//app.map=app.map.resize(app.map.width, app.map.height%20+5)
	app.size = 10 + (app.size % 50)
	btn.text="size: $app.size"
	handle_size(mut app, app.window_width, app.window_height)
}

fn mouse_down (mut app &App, e ui.MouseEvent) {
	c, x, y := grid_click(app, e.x, e.y)
	if e.button == .left {
		// TODO: recognise click on menu
		app.menu.visible = false
		if c{
			app.map.pattern[x][y] = !app.map.pattern[x][y]
			app.drag_state = app.map.pattern[x][y]
			app.mouse_down = true
		}
	} else {
			if c {
//println("_1")
			//mut s:= app.window
//println("_2")
			/*if s is ui.Stack {
				println("ist Stack")
			}*/
			app.menu.visible = true
			app.menu.x = x
			app.menu.y = y
			app.menu.orientation_x = if x >= app.map.width / 2 {1} else {0}
			app.menu.orientation_y = if y >= app.map.height / 2 {1} else {0}
			app.menu.resize(app.map.width, app.map.height)
			}
	}
}

fn mouse_up (mut app &App) {
	app.mouse_down = false
}

fn mouse_move (mut app &App, xx int, yy int) {
	if app.mouse_down{
		c, x, y := grid_click(app, xx, yy)
		if c {		
				if !app.map.pattern[x][y] == app.drag_state {
					app.map.pattern[x][y] = app.drag_state
					//app.window.refresh()
				}	
		}
	}
}

fn grid_click (app &App, x int, y int) (bool, int, int) {
	if !app.start {
			px:= (x - grid_padding - app.margin_left) / (app.size + padding)
			py:= (y - grid_padding - app.margin_top - margin_top_to_grid) / (app.size + padding)

			return x > (grid_padding + app.margin_left) && y > (grid_padding + app.margin_top + margin_top_to_grid) &&  px < app.map.width && py < app.map.height, px, py
	}
	return false, 0, 0
}

fn start_stop(mut app App, mut btn &ui.Button) {
		if app.start {
			app.start=false
			btn.text="start"
		} else {
			app.start=true
			btn.text="stop"
			go app.run()
		}
}

fn (mut menu Menu) resize (width int, height int) {
	menu.width = f32(width) * menu.max_size
	menu.height = f32(height) * menu.max_size
	
	if menu.width / menu.height > menu.ratio {
		menu.width = menu.height * menu.ratio
	} else {
		menu.height = menu.width / menu.ratio
	}
}

fn handle_size(mut app App, w int, h int) {

		app.window_width = w
		app.window_height = h
		
		map_width := (w - 2 * grid_padding + padding) / (app.size + padding)
		map_height := (h - 2 * grid_padding - margin_top_to_grid + padding) / (app.size + padding)

		app.margin_left = (w - 2 * grid_padding - (app.size + padding) * map_width + padding) / 2
		app.margin_top = (h - 2 * grid_padding - margin_top_to_grid - (app.size + padding) * map_height + padding) / 2

		app.btn_nm.x = w - margin_left - app.btn_nm.width
		app.btn_size.x = w / 2 - app.btn_size.width / 2

		app.map.resize(map_width, map_height)
		//app.menu.resize(map_width, map_height)

		//app.btn_row.x = app.btn_col.x + app.btn_col.width
}

fn (mut app App) run() {

	for app.start {
		app.map.simulate()
		app.window.refresh()
		time.sleep_ms(1000/sps)
	}
}

fn draw_c(gg &gg.Context, mut app &App, can &ui.Canvas) {

	// draw background color of grid
	gg.draw_rect(app.margin_left, margin_top_to_grid+app.margin_top, (app.size+padding)*app.map.width-padding+2*grid_padding, (app.size+padding)*app.map.height-padding+2*grid_padding, bg_grid)
	
	//draw grid
	for w in 0..app.map.width {
		for h in 0..app.map.height {
			// TODO: set colors in array => choose from them
			gg.draw_rect((padding+app.size)*w+grid_padding+app.margin_left, (padding+app.size)*h+margin_top_to_grid+grid_padding+app.margin_top, app.size, app.size, if app.map.pattern[w][h] {life} else {dead} )
		}
	}

	if app.menu.visible {
		menu:=app.menu
		width := menu.width * (app.size + padding)
		height := menu.height * (app.size + padding)
		x := menu.x * (app.size + padding) - padding + app.margin_left + grid_padding + app.size - menu.orientation_x * (width - 2 * padding + app.size) //+ (1 - menu.orientation_x) * app.size
		y := menu.y * (app.size + padding) - padding + app.margin_top + margin_top_to_grid + grid_padding + app.size - menu.orientation_y * (height - 2 * padding + app.size) //+ (1 - menu.orientation_y) * app.size
		gg.draw_rect(x, y, width, height, gx.red)
		mx := menu.x * (app.size + padding) + app.margin_left + grid_padding
		my := menu.y * (app.size + padding) + margin_top_to_grid + app.margin_top + grid_padding
		gg.draw_empty_square(mx, my, app.size, highlight_color)
		gg.draw_empty_square(mx + 1, my + 1, app.size - 2, highlight_color)
		gg.draw_empty_square(mx + 2, my + 2, app.size - 4, highlight_color)
	}
	
}

