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
	margin_top_to_grid=36
	size		=30
	padding		=4
	grid_padding	=8
	dead		=gx.white
	life		=gx.black
	bg_win		=gx.rgb(200, 200, 200)
	bg_grid		=gx.rgb(120, 120, 120)
	win_width  = row*(padding+size)-padding+2*grid_padding
	win_height = col*(padding+size)-padding+2*grid_padding+margin_top_to_grid
)

struct App {
mut:
	window &ui.Window = 0
	start	bool
	watch	time.StopWatch
	map	Map={
		pattern:create_map(row, col, 0)
		width:row
		height:col
	}
}

fn main() {
	mut app := &App{
	watch:time.new_stopwatch({auto_start:false})
	}
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
		}, [
			ui.button({
				width: 80
				height: 30
				text: "start"
				onclick:start_stop
				}),
			ui.button({
				width: 110
				height: 30
				text: "$col columns"
				onclick:click_column
				})
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
			app.watch.pause()
		} else {
			app.start=true
			btn.text="stop"
			app.watch.restart()
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
	gg.draw_rect(0, margin_top_to_grid, (size+padding)*app.map.width-padding+2*grid_padding, (size+padding)*app.map.height-padding+2*grid_padding, bg_grid)
	
	//draw grid
	for w in 0..app.map.width {
		for h in 0..app.map.height {
			gg.draw_rect((padding+size)*w+grid_padding, (padding+size)*h+margin_top_to_grid+grid_padding, size, size, if app.map.pattern[w][h] {life} else {dead} )
		}
	}
}
