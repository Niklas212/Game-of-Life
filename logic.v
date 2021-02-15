module main

import rand

struct Map {
	mut:
	pattern [][]bool
	width int
	height int
}
/*
struct IMap {
	mut:
	pattern [][]int
	width	int
	height	int
}
*/
fn create_map(w int, h int) [][]bool {
	mut m:=[][]bool{len:w, init: []bool{len:h}}
	
	for i in 0..w{
		for ii in 0..h{
				m[i][ii]= if rand.intn(2)==1 {true} else {false}
				}
	}
	return m
}

fn (mut map Map) simulate () {
	mut score:=[][]int{len:map.width, init: []int{len:map.height}}
	//mut as:=0
	//top-left
	if map.pattern[0][0] {
		score[0][1] ++
		score[1][0] ++
		score[1][1] ++
	}

	//bottom-left
	if map.pattern[0][map.height-1] {
		score[0][map.height-2] ++
		score[1][map.height-1] ++
		score[1][map.height-2] ++
	}

	//top-right
	if map.pattern[map.width-1][0] {
		score[map.width-2][0] ++
		score[map.width-1][1] ++
		score[map.width-2][1] ++
	}
	//bottom-right
	if map.pattern [map.width-1][map.height-1] {
		score[map.width-1][map.height-2] ++
		score[map.width-2][map.height-1] ++
		score[map.width-2][map.height-2] ++
	}

	for x in 1..map.width - 1 {
		if map.pattern[x][0] {
			score[x-1][0] ++
			score[x+1][0] ++
			score[x][1] ++
			score[x-1][1] ++
			score[x+1][1] ++
		}
		if map.pattern [x][map.height-1] {
			score[x-1][map.height-1] ++
			score[x+1][map.height-1] ++
			score[x][map.height - 2] ++
			score[x-1][map.height - 2] ++
			score[x+1][map.height - 2] ++
		}
	}

	for  y in 1..map.height - 1 {
		if map.pattern[0][y] {
			score [0][y+1] ++
			score [0][y-1] ++
			score [1][y+1] ++
			score [1][y-1] ++
			score [1][y] ++
		}
		if map.pattern [map.width-1][y] {
			score [map.width-1][y+1] ++
			score [map.width-1][y-1] ++
			score [map.width-2][y] ++
			score [map.width-2][y+1] ++
			score [map.width-2][y-1] ++
		}
	}

	for  x in 1..map.width - 1 {
		for  y in 1..map.height - 1 {
			if map.pattern[x][y] {
				score[x-1][y] ++
				score[x+1][y] ++
				score[x][y+1] ++
				score[x][y-1] ++
				score[x-1][y+1] ++
				score[x+1][y+1] ++
				score[x-1][y-1] ++
				score[x+1][y-1] ++
			}
		}
	}
	
	//set new values
	for  w in 0..map.width {
		for  h in 0..map.height {
			if map.pattern[w][h] {
				if score[w][h]==2 || score[w][h]==3 {
					map.pattern[w][h]=true
				} else {
					map.pattern[w][h]=false
				}
			}
			else {
				if score[w][h]==3 {map.pattern[w][h]=true}
			}
		}
	}
}
/*
 
fn (mut map Map)simulate() {
	mut nm:=map.pattern.clone()
	m:=map.pattern
	
	mut atop:=false
	mut adown:=false
	mut aleft:=false
	mut aright:=false
	
	for h in 0..map.height {
		atop= if h>0 {true} else {false}
		adown= if map.height>h+1 {true} else {false}
		
		for w in 0..map.width {
			mut neigh:=0
			aleft= if w>0 {true} else {false}
			aright= if map.width>w+1 {true} else {false}
			
			if aleft && m[w-1][h] {neigh++}
			if aright && m[w+1][h] {neigh++}
			if atop && m[w][h-1] {neigh++}
			if adown && m[w][h+1] {neigh++}
			
			if aleft && atop && m[w-1][h-1] {neigh++}
			if aleft && adown && m[w-1][h+1] {neigh++}
			if aright && atop && m[w+1][h-1] {neigh++}
			if aright && adown && m[w+1][h+1] {neigh++}
			
			if nm[w][h] {
				if neigh==2 || neigh==3 {
					nm[w][h]=true
				} else {
					nm[w][h]=false
				}
			}
			else {
				if neigh==3 {nm[w][h]=true}
			}
		}
	}
	
	map.pattern=nm
}
*/

fn (m Map) resize(w int, h int) Map {
	mut nm:=[][]bool{len:w, init:[]bool{len:h}}
	min_width:=if m.width>w {w} else {m.width}
	min_height:=if m.height>h {h} else {m.height}
	for x in 0..min_width {
		for y in 0..min_height {
			nm[x][y]=m.pattern[x][y]
		}
	}
	return Map{pattern:nm, width:w, height:h}
}
