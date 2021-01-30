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
	margin_top_to_grid=36
	padding		=4
	grid_padding	=12
	dead		=gx.white
	life		=gx.black
	bg_win		=gx.rgb(200, 200, 200)
	bg_grid		=gx.rgb(120, 120, 120)
	win_width  = 700
	win_height = 396
	//btn_map_width = 80
	//btn_start_width = 80
	//btn_row_width = 110
	//btn_col_width = 110
)

struct App {
mut:
	window &ui.Window = 0
	start	bool
	size	int =30
	margin_top int
	margin_left int
	
	map	Map={
		pattern:create_map(row, col, 0)
		width:row
		height:col
	}
}

fn main() {
	
	mut app := &App{}
	window := ui.window({
		width: win_width
		height: win_height
		bg_color:bg_win
		title: 'GAME OF LIFE'
		resizable: true
		state: app
	}, [
		ui.canvas({
					width  	:400
					height  :250
					draw_fn:draw_c
				}),
		ui.row({
			stretch: true
			margin: ui.MarginConfig{8, 8, 8, 8}
			spacing: 0
		}, [	ui.button({
				width: 80
				height: 30
				text: "start"
				onclick:start_stop
				}),
			ui.button({
				width:110
				height: 30
				text: "$col columns"
				onclick:click_column
				}),
			ui.button({
				width: 110
				height: 30
				text: "$row rows"
				onclick:click_row
				}),
			ui.button({
				width: 80
				height: 30
				text: "new map"
				onclick:new_map
				}),
				
		]),
	])
	app.window = window
	go app.run()
	go app.handle_size(if sapp.dpi_scale()==0.0 {1.0} else {sapp.dpi_scale()})
	ui.run(window)
}
fn new_map (mut app &App, mut btn &ui.Button) {
	app.map.pattern=create_map(app.map.width, app.map.height, 0)
}

fn click_column (mut app &App, mut btn &ui.Button) {
	app.map=app.map.resize(app.map.width, app.map.height%20+5)
	btn.text="$app.map.height columns"
}

fn click_row (mut app &App, mut btn &ui.Button) {
	app.map=app.map.resize(app.map.width%40+10, app.map.height)
	btn.text="$app.map.width rows"
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

fn (mut app App) handle_size(scale f32) {
	mut w, mut h, mut uh, mut uw, mut hs, mut ws:=0, 0, 0, 0, 0, 0
	//app.btn_padding_right=300
	for {
		w = int(sapp.width() / scale)
		h = int(sapp.height() / scale)
		
		uh = (h - margin_top_to_grid - 2 * grid_padding - (app.map.height-1) * padding)
		uw = (w - 2 * grid_padding - (app.map.width) * padding)
		
		hs = uh / app.map.height
		ws = uw / app.map.width
	
		app.size = if hs > ws {ws} else {hs}
		
		app.margin_left = (uw - app.size * app.map.width) / 2
		app.margin_top = (uh - app.size * app.map.height) / 2
	}
}

fn (mut app App) run() {
	for {
		if app.start {
			app.map.simulate()
		}
		time.sleep_ms(1000/sps)
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
