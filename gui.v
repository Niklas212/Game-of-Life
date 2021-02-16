module main

import ui
import gg
import gx
import time
import sokol.sapp

const (
	col		=10
	row		=20
	//simulations per second
	sps		=4
	margin_left	= 8
	margin_top_to_grid=30
	padding		=4
	grid_padding	=12
	dead		=gx.white
	life		=gx.black
	bg_win		=gx.rgb(200, 200, 200)
	bg_grid		=gx.rgb(120, 120, 120)
	win_width  = 700
	win_height = 390
)

struct App {
mut:
	window &ui.Window = 0
	start	bool
	size	int =30
	margin_top int
	margin_left int
	btn_nm		&ui.Button = 0
	btn_start	&ui.Button = 0
	btn_row		&ui.Button = 0
	btn_col		&ui.Button = 0
	
	map	Map={
		pattern:create_map(row, col)
		width:row
		height:col
	}
}

fn main() {
	
	mut app := &App{}
	
	//scale:=if sapp.dpi_scale()==0.0 {1.0} else {sapp.dpi_scale()}
	//scale:=1
	
	fn_mouse_down:= fn (e ui.MouseEvent, mut window &ui.Window) {
	mouse_down(mut window.state, e)
}

	app.btn_nm = ui.button({
		width: 80
		height: 30
		text: "new map"
		onclick:new_map
	})
	
	app.btn_start = ui.button({
		width: 80
		height: 30
		text: "start"
		onclick:start_stop
				})
	
	app.btn_col = ui.button({
		width:100
		height: 30
		text: "$col columns"
		onclick:click_column
				})
				
	app.btn_row = ui.button({
		width: 100
		height: 30
		text: "$row rows"
		onclick:click_row
				})
				
	
	window := ui.window({
		width: win_width
		height: win_height
		bg_color:bg_win
		title: 'GAME OF LIFE'
		resizable: true
		on_mouse_down: fn_mouse_down
		state: app
	}, [
		ui.canvas({
				width  	:400
				height  :250
				draw_fn:draw_c
			}),
			app.btn_start,
			app.btn_col,
			app.btn_row,
			app.btn_nm	
	])
	app.window = window
	go app.run()
	go app.handle_size()
	ui.run(window)
}

fn new_map (mut app &App, mut btn &ui.Button) {
	app.map.pattern=create_map(app.map.width, app.map.height)
}

fn click_column (mut app &App, mut btn &ui.Button) {
	app.map=app.map.resize(app.map.width, app.map.height%20+5)
	btn.text="$app.map.height columns"
}

fn click_row (mut app &App, mut btn &ui.Button) {
	app.map=app.map.resize(app.map.width%40+10, app.map.height)
	btn.text="$app.map.width rows"
}


fn mouse_down (mut app &App, e ui.MouseEvent) {
	
	if !app.start {
	//checks if click is in grid
		if e.x > (app.margin_left + grid_padding) && e.y > app.margin_top + margin_top_to_grid && e.x < (sapp.width() - app.margin_left - grid_padding) && e.y < sapp.height() - app.margin_top - grid_padding{
			x:= (e.x - grid_padding - app.margin_left) / (app.size + padding)
			y:= (e.y - grid_padding - app.margin_top - margin_top_to_grid) / (app.size + padding)
			//println("$x, $y")
			app.map.pattern[x][y]=!app.map.pattern[x][y]

		}
	}
}

fn start_stop(mut app App, mut btn &ui.Button) {
		if app.start {
			app.start=false
			btn.text="start"
		} else {
			app.start=true
			btn.text="stop"
		}
}

fn (mut app App) handle_size() {
	mut w, mut h, mut uh, mut uw, mut hs, mut ws:=0, 0, 0, 0, 0, 0
	app.btn_col.y = 4
	app.btn_row.y = 4
	app.btn_start.y = 4
	app.btn_start.x = margin_left
	app.btn_nm.y = 4
	for {
		w = int(sapp.width())
		h = int(sapp.height())
		
		uh = (h - margin_top_to_grid - 2 * grid_padding - (app.map.height-1) * padding)
		uw = (w - 2 * grid_padding - (app.map.width - 1) * padding)
		
		hs = uh / app.map.height
		ws = uw / app.map.width
	
		app.size = if hs > ws {ws} else {hs}
		
		app.margin_left = (uw - app.size * app.map.width) / 2
		app.margin_top = (uh - app.size * app.map.height) / 2
		
		app.btn_nm.x = w - margin_left - app.btn_nm.width

		app.btn_col.x = w / 2 - app.btn_col.width
		app.btn_row.x = app.btn_col.x + app.btn_col.width
	}
}

fn (mut app App) run() {
	for {
		if app.start {
			app.map.simulate()
			app.window.refresh()
			time.sleep_ms(1000/sps)
		}
		
	}
}

fn draw_c(gg &gg.Context, mut app &App) {
	
	// draw background color of grid
	gg.draw_rect(app.margin_left, margin_top_to_grid+app.margin_top, (app.size+padding)*app.map.width-padding+2*grid_padding, (app.size+padding)*app.map.height-padding+2*grid_padding, bg_grid)
	
	//draw grid
	for w in 0..app.map.width {
		for h in 0..app.map.height {
			gg.draw_rect((padding+app.size)*w+grid_padding+app.margin_left, (padding+app.size)*h+margin_top_to_grid+grid_padding+app.margin_top, app.size, app.size, if app.map.pattern[w][h] {life} else {dead} )
		}
	}
}

