module main

import rand

struct Map {
	mut:
	pattern [][]bool
	width int
	height int
}

fn create_map(w int, h int, border int) [][]bool {
	mut m:=[][]bool{len:w+border*2, init: []bool{len:h+border*2}}
	
	for i in border..w+border{
		for ii in border..h+border{
				m[i][ii]= if rand.intn(2)==1 {true} else {false}
				}
	}
	return m
}


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
