;; By Kenny Fully. May GOD bless.
;; chāo hóng dú jiǎo shòu
(module
	(import "fx" "sfx" (func $sfx (param i32)))
	(import "fx" "sfm" (func $sfm (param i32)))
	(import "fx" "sfs" (func $sfs (param i32)))
	(memory (export "memory") 10) ;; 10 pages = 655360 bytes

	(global $cam_xy     (mut i32) (i32.const   144))
	(global $has_map    (mut i32) (i32.const     0)) ;; 1 = true
	(global $hearts     (mut i32) (i32.const     0)) ;; max 4
	(global $player_dx  (mut i32) (i32.const   464))
	(global $player_dy  (mut i32) (i32.const   448))
	(global $player_dir (mut i32) (i32.const     1))
	(global $power_mode (mut i32) (i32.const     0)) ;; max 3
	(global $rgb_orbs   (mut i32) (i32.const     0)) ;; max 3
	(global $special_trees_touched (mut i32) (i32.const 0)) ;; max 4
	(global $special_trees_burned  (mut i32) (i32.const 0)) ;; max 25
		
	(func $init
	    (local $i   i32) (local $addr  i32)
	    (local $src i32) (local $dst   i32) (local $len i32)
	    (local $end i32) (local $count i32) (local $val i32)
	    i32.const 501742
	    local.set $addr
	    loop $loop_i
	        local.get $addr
	        i32.load
	        local.set $src
	        local.get $addr
	        i32.load offset=4
	        local.set $dst
	        local.get $addr
	        i32.load offset=8
	        local.set $len
	        local.get $src
	        local.get $len
	        i32.add
	        local.set $end
	        block $break_loop
	            loop $loop
	                local.get $src
	                local.get $end
	                i32.ge_u
	                br_if $break_loop
	                local.get $src
	                i32.load8_u
	                local.set $count
	                local.get $src
	                i32.load8_u offset=1
	                local.set $val
	                local.get $src
	                i32.const 2
	                i32.add
	                local.set $src
	                loop $fill
	                    local.get $dst
	                    local.get $val
	                    i32.store8
	                    local.get $dst
	                    i32.const 1
	                    i32.add
	                    local.set $dst
	                    local.get $count
	                    i32.const 1
	                    i32.sub
	                    local.tee $count
	                    br_if $fill
	                end
	                br $loop
	            end
	        end
	        local.get $addr
	        i32.const 12
	        i32.add
	        local.set $addr
	        local.get $i
	        i32.const 1
	        i32.add
	        local.tee $i
	        i32.const 8
	        i32.lt_u
	        br_if $loop_i
	    end
		;; turn base power on
		i32.const 476187 ;; mem_addr powers
		i32.const 1
		i32.store8
	)

	(func $render_bg (param $clr_abgr i32) (local $i i32)
		loop $loop_i
			local.get $i
			local.get $clr_abgr
			i32.store
			local.get $i
			i32.const 4
			i32.add
			local.tee $i
			i32.const 409600
			i32.lt_u
			br_if $loop_i
		end
	)

	(func $render_char
	    (param $ndx    i32)
	    (param $clr_00 i32)
	    (param $clr_02 i32)
	    (param $dx     i32)
	    (param $dy     i32)
	    (param $scale  i32)
		    i32.const 450560     ;; mem_addr charset_8x16x48v
		    local.get $ndx       ;;
		    i32.const 128        ;;
		    i32.mul              ;;
		    i32.add              ;;
		    local.get $clr_00    ;; color_abgr_00
		    i32.const 0xFF808080 ;; color_abgr_01
		    local.get $clr_02    ;; color_abgr_02
		    local.get $dx        ;; dx
		    local.get $dy        ;; dy
		    i32.const 8          ;; dw
		    i32.const 16         ;; dh
		    local.get $scale     ;; scale
		    i32.const 0          ;; flip_x
		    i32.const 0          ;; flip_y
		    call $render_image
	)

	(func $render_hud (local $i i32) (local $j i32)
	    i32.const 0xFF101010 ;; clr_abgr
	    i32.const 0          ;; dx
	    i32.const 0          ;; dy
	    i32.const 320        ;; dw
	    i32.const 32         ;; dh
	    call $render_rect

		call $render_hud_hearts
		
		global.get $has_map
		i32.const 1
		i32.ge_u
		if
			;; map set
		    i32.const 473856     ;; mem_addr
		    i32.const 64
		    i32.const 2 ;; map icon
		    i32.mul
		    i32.add
		    i32.const 0xFF8080FF ;; clr_abgr_00
		    i32.const 0xFF0000FF ;; clr_abgr_01
		    i32.const 0xFFFFFFFF ;; clr_abgr_02
		    i32.const 160        ;; dx
		    i32.const 4
		    i32.add
		    i32.const 4          ;; dy
		    i32.const 8          ;; dw
		    i32.const 8          ;; dh
		    i32.const 3          ;; scale
		    i32.const 0          ;; flip_x
		    i32.const 0          ;; flip_y
		    call $render_image
		    ;; mini game map
		    i32.const 476192     ;; mem_addr game_map
		    i32.const 0xFF808080 ;; clr_abgr_00
		    i32.const 0xFFFFFFFF ;; clr_abgr_01
		    i32.const 0xFF000000 ;; clr_abgr_02
		    i32.const 276        ;; dx
		    i32.const 36         ;; dy
		    i32.const 40         ;; dw
		    i32.const 40         ;; dh
		    i32.const 1          ;; scale
		    i32.const 0          ;; flip_x
		    i32.const 0          ;; flip_y
		    call $render_image
		end
		
	    ;; j
	    i32.const 473856     ;; mem_addr
	    i32.const 64
	    i32.const 5
	    i32.mul
	    i32.add
	    i32.const 0xFF8080FF ;; clr_abgr_00
	    i32.const 0xFF0000FF ;; clr_abgr_01
	    i32.const 0xFFFFFFFF ;; clr_abgr_02
	    i32.const 192        ;; dx
	    i32.const 4
	    i32.add
	    i32.const 4          ;; dy
	    i32.const 8          ;; dw
	    i32.const 8          ;; dh
	    i32.const 3          ;; scale
	    i32.const 0          ;; flip_x
	    i32.const 0          ;; flip_y
	    call $render_image

		i32.const 0
		local.set $i
		loop $loop_i
		    i32.const 0
		    local.set $j
		    loop $loop_j
		        i32.const 476187
		        local.get $i
		        i32.const 2
		        i32.mul
		        local.get $j
		        i32.add
		        i32.add
		        i32.load8_u
		        i32.const 1
		        i32.eq
		        if
					global.get $power_mode
			        local.get $i
			        i32.const 2
			        i32.mul
			        local.get $j
			        i32.add
					i32.eq
					
					i32.const 476184     ;; timer_256
					i32.load8_u
					i32.const 64
					i32.rem_u
					i32.const 32
					i32.lt_u
					i32.and
					if
					    i32.const 0xFF808080 ;; clr_abgr
			            i32.const 224
			            local.get $i
			            i32.const 16
			            i32.mul
			            i32.add        ;; dx = 224 + i*16
			            local.get $j
			            i32.const 16
			            i32.mul        ;; dy
			            i32.const 16
			            i32.const 16
					    call $render_rect
					end
		            i32.const 473856
		            i32.const 256
		            i32.add
		            i32.const 0xFF8080FF ;; clr_00
		            i32.const 0xFF0000FF ;; clr_01
					;;
					i32.const 477792 ;; solid color
			        local.get $i
			        i32.const 2
			        i32.mul
			        local.get $j
			        i32.add
					i32.const 4
					i32.mul
					i32.add
					i32.load           ;; clr_02
					;;
		            i32.const 224
		            local.get $i
		            i32.const 16
		            i32.mul
		            i32.add        ;; dx = 224 + i*16
		            local.get $j
		            i32.const 16
		            i32.mul        ;; dy
		            i32.const 8
		            i32.const 8
		            i32.const 2
		            i32.const 0
		            i32.const 0
		            call $render_image
		        end
		        local.get $j
		        i32.const 1
		        i32.add
		        local.tee $j
		        i32.const 2
		        i32.lt_u
		        br_if $loop_j
		    end
		    local.get $i
		    i32.const 1
		    i32.add
		    local.tee $i
		    i32.const 2
		    i32.lt_u
		    br_if $loop_i
		end
				
	    ;; k
	    i32.const 473856     ;; mem_addr
	    i32.const 64
	    i32.const 6
	    i32.mul
	    i32.add
	    i32.const 0xFF8080FF ;; clr_abgr_00
	    i32.const 0xFF0000FF ;; clr_abgr_01
	    i32.const 0xFFFFFFFF ;; clr_abgr_02
	    i32.const 256        ;; dx
	    i32.const 4
	    i32.add
	    i32.const 4          ;; dy
	    i32.const 8          ;; dw
	    i32.const 8          ;; dh
	    i32.const 3          ;; scale
	    i32.const 0          ;; flip_x
	    i32.const 0          ;; flip_y
	    call $render_image

	    ;; power
	    i32.const 473856     ;; mem_addr
	    i32.const 64
	    i32.const 7
	    i32.mul
	    i32.add
	    i32.const 0xFF8080FF ;; clr_abgr_00
	    i32.const 0xFF0000FF ;; clr_abgr_01
	    i32.const 0xFFFFFFFF ;; clr_abgr_02
	    i32.const 288          ;; dx
	    i32.const 4
	    i32.add
	    i32.const 4          ;; dy
	    i32.const 8          ;; dw
	    i32.const 8          ;; dh
	    i32.const 3          ;; scale
	    i32.const 0          ;; flip_x
	    i32.const 0          ;; flip_y
	    call $render_image

		global.get $rgb_orbs
		i32.const 3
		i32.lt_u
		if
		    i32.const 0xFF101010 ;; clr_abgr
		    i32.const 0          ;; dx
		    i32.const 284        ;; dy
		    i32.const 320        ;; dw
		    i32.const 24         ;; dh
		    call $render_rect
		    i32.const 501957
		    i32.const 25
		    i32.const 0xFFFFFFFF
		    i32.const 0xFF000000
		    i32.const 16
		    i32.const 288
		    i32.const 1
		    call $render_word
		end
	)	

	(func $render_hud_hearts (local $i i32)
		global.get $hearts
		i32.const 0
		i32.ne
		if
			loop $loop_i
			    i32.const 473856     ;; mem_addr
			    i32.const 0xFF8080FF ;; clr_abgr_00
			    i32.const 0xFF0000FF ;; clr_abgr_01
			    i32.const 0xFFFFFFFF ;; clr_abgr_02
				local.get $i
			    i32.const 32         
				i32.mul              
				i32.const 4
				i32.add              ;; dx
			    i32.const 4          ;; dy
			    i32.const 8          ;; dw
			    i32.const 8          ;; dh
			    i32.const 3          ;; scale
			    i32.const 0          ;; flip_x
			    i32.const 0          ;; flip_y
			    call $render_image
				local.get $i
				i32.const 1
				i32.add
				local.tee $i
				global.get $hearts
				i32.lt_u
				br_if $loop_i
			end
		end
	)

	(func $render_image
	    (param $img   i32) (param $clr_00 i32) (param $clr_01  i32) (param $clr_02  i32)
	    (param $dx    i32) (param $dy     i32) (param $dw      i32) (param $dh      i32)
	    (param $scale i32) (param $flip_x i32) (param $flip_y  i32)
	    (local $i     i32) (local $j      i32) (local $des_mem i32) (local $clr_ndx i32)
	    (local $src_i i32) (local $src_j  i32) (local $clr i32)
	    loop $loop_i
	        local.get $i
	        local.get $dh
	        local.get $scale
	        i32.mul
	        i32.ge_u
	        br_if 1
	        local.get $i
	        local.get $scale
	        i32.div_u
	        local.set $src_i
	        local.get $flip_y
	        if
	            local.get $dh
	            i32.const 1
	            i32.sub
	            local.get $src_i
	            i32.sub
	            local.set $src_i
	        end
	        local.get $i
	        local.get $dy
	        i32.add
	        local.tee $des_mem
	        i32.const 0
	        i32.ge_s
	        local.get $des_mem
	        i32.const 320
	        i32.lt_s
	        i32.and
	        if
	            i32.const 0
	            local.set $j
	            loop $loop_j
	                local.get $j
	                local.get $dw
	                local.get $scale
	                i32.mul
	                i32.ge_u
	                br_if 1 
	                local.get $j
	                local.get $scale
	                i32.div_u
	                local.set $src_j
	                local.get $flip_x
	                if
	                    local.get $dw
	                    i32.const 1
	                    i32.sub
	                    local.get $src_j
	                    i32.sub
	                    local.set $src_j
	                end
	                local.get $j
	                local.get $dx
	                i32.add
	                local.tee $des_mem
	                i32.const 0
	                i32.ge_s
	                local.get $des_mem
	                i32.const 320
	                i32.lt_s
	                i32.and
	                if
	                    local.get $img
	                    local.get $src_i
	                    local.get $dw
	                    i32.mul
	                    local.get $src_j
	                    i32.add
	                    i32.add
	                    i32.load8_u
	                    local.tee $clr_ndx
	                    ;; strict: only 1, 2, 3 are opaque; 0 and 4+ are skipped
	                    i32.const 1
	                    i32.sub
	                    i32.const 3
	                    i32.lt_u
	                    if
	                        ;; resolve color into $clr (default = clr_00 for index 1)
	                        local.get $clr_00
	                        local.set $clr
	                        local.get $clr_ndx
	                        i32.const 2
	                        i32.eq
	                        if
	                            local.get $clr_01
	                            local.set $clr
	                        else
	                            local.get $clr_ndx
	                            i32.const 3
	                            i32.eq
	                            if
	                                local.get $clr_02
	                                local.set $clr
	                            end
	                        end
	                        ;; compute address and store
	                        local.get $i
	                        local.get $dy
	                        i32.add
	                        i32.const 1280
	                        i32.mul
	                        local.get $j
	                        local.get $dx
	                        i32.add
	                        i32.const 2
	                        i32.shl
	                        i32.add
	                        local.get $clr
	                        i32.store
	                    end
	                end
	                local.get $j
	                i32.const 1
	                i32.add
	                local.set $j
	                br $loop_j
	            end
	        end
	        local.get $i
	        i32.const 1
	        i32.add
	        local.set $i
	        br $loop_i
	    end
	)

	(func $render_map
		(local $i  i32) (local $j  i32)
		(local $tx i32) (local $ty i32)
	    loop $loop_i
	        i32.const 0
	        local.set $j ;; tile_x
	        loop $loop_j
	            i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 1
	            i32.eq
	            if
	                i32.const 0xFF0000FF ;; clr_abgr
	                i32.const 32
	                local.get $j          ;; dx
	                i32.mul
	                global.get $player_dx
	                i32.sub
	                global.get $cam_xy   ;; 144
	                i32.add
	                i32.const 32
	                local.get $i
	                i32.mul               ;; dy
	                global.get $player_dy
	                i32.sub
	                global.get $cam_xy   ;; 144
	                i32.add
	                i32.const 32         ;; dw
	                i32.const 32        ;; dh
	                call $render_rect
	            end
				
	            ;; cloud_16x16
	            i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 2
	            i32.eq
	            i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 3
	            i32.eq
	            i32.or
	            if
	                i32.const 473344
	                i32.const 0xFF808080
	                i32.const 0xFFA0A0FF
	                i32.const 0xFFFFFFFF
	                i32.const 32
	                local.get $j          ;; dx
	                i32.mul
	                global.get $player_dx
	                i32.sub
	                global.get $cam_xy   ;; 144
	                i32.add
	                i32.const 32
	                local.get $i
	                i32.mul               ;; dy
	                global.get $player_dy
	                i32.sub
	                global.get $cam_xy   ;; 144
	                i32.add
	                i32.const 16        ;; dw
	                i32.const 16        ;; dh
	                i32.const 2         ;; scale
	                i32.const 0         ;; flip_x
	                i32.const 0         ;; flip_y
	                call $render_image
	            end

	            ;; rgb_orb_green
	            i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 4
	            i32.eq
	            if
					i32.const 0
					local.get $j
					local.get $i 
					call $render_rgb_orb
	            end

	            ;; rgb_orb_red
	            i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 5
	            i32.eq
	            if
					i32.const 1
					local.get $j
					local.get $i 
					call $render_rgb_orb
	            end

	            ;; rgb_orb_blue
	            i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 6
	            i32.eq
	            if
					i32.const 2
					local.get $j
					local.get $i 
					call $render_rgb_orb
	            end

	            ;; rgb_orb_rainbow
	            i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 7
	            i32.eq
	            if
	                i32.const 473600
	                i32.const 476160
					i32.load
	                i32.const 476164
					i32.load
	                i32.const 0xFFFFFFFF
	                i32.const 32
	                local.get $j          ;; dx
	                i32.mul
	                global.get $player_dx
	                i32.sub
	                global.get $cam_xy   ;; 144
	                i32.add
	                i32.const 32
	                local.get $i
	                i32.mul               ;; dy
	                global.get $player_dy
	                i32.sub
	                global.get $cam_xy   ;; 144
	                i32.add
	                i32.const 16        ;; dw
	                i32.const 16        ;; dh
	                i32.const 4         ;; scale
	                i32.const 0         ;; flip_x
	                i32.const 0         ;; flip_y
	                call $render_image
	            end

		        ;; rainbow_cloud_16x16
		        i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 8
	            i32.eq
		        if
		            i32.const 473344
		            i32.const 476160
					i32.load
		            i32.const 476164
					i32.load
		            i32.const 0xFFFFFFFF
		            i32.const 32
		            local.get $j          ;; dx
		            i32.mul
		            global.get $player_dx
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 32
		            local.get $i
		            i32.mul               ;; dy
		            global.get $player_dy
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 16        ;; dw
		            i32.const 16        ;; dh
		            i32.const 2         ;; scale
		            i32.const 0         ;; flip_x
		            i32.const 0         ;; flip_y
		            call $render_image
		        end

		        ;; map_set
		        i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 9
	            i32.eq
		        if
					;;
				    i32.const 473856     ;; mem_addr
				    i32.const 64
				    i32.const 2 ;; map icon
				    i32.mul
				    i32.add
					;;
		            i32.const 476160
					i32.load
		            i32.const 476164
					i32.load
		            i32.const 0xFFFFFFFF
		            i32.const 32
		            local.get $j          ;; dx
		            i32.mul
		            global.get $player_dx
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 32
		            local.get $i
		            i32.mul               ;; dy
		            global.get $player_dy
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 8        ;; dw
		            i32.const 8        ;; dh
		            i32.const 4         ;; scale
		            i32.const 0         ;; flip_x
		            i32.const 0         ;; flip_y
		            call $render_image
		        end

		        ;; button_00
		        i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x0A ;; button_00_f1
	            i32.eq
		        if
					;;
				    i32.const 473856     ;; mem_addr
				    i32.const 64
				    i32.const 10 ;; button_00
				    i32.mul
				    i32.add
					;;
		            i32.const 476160
					i32.load
		            i32.const 476164
					i32.load
		            i32.const 0xFFFFFFFF
		            i32.const 32
		            local.get $j          ;; dx
		            i32.mul
		            global.get $player_dx
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 32
		            local.get $i
		            i32.mul               ;; dy
		            global.get $player_dy
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 8        ;; dw
		            i32.const 8        ;; dh
		            i32.const 4         ;; scale
		            i32.const 0         ;; flip_x
		            i32.const 0         ;; flip_y
		            call $render_image
		        end

		        ;; button_00_f2
		        i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x0B ;; button_00_f2
	            i32.eq
		        if
					;;
				    i32.const 473856     ;; mem_addr
				    i32.const 64
				    i32.const 11 ;; button_00_f2
				    i32.mul
				    i32.add
					;;
		            i32.const 476160
					i32.load
		            i32.const 476164
					i32.load
		            i32.const 0xFFFFFFFF
		            i32.const 32
		            local.get $j          ;; dx
		            i32.mul
		            global.get $player_dx
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 32
		            local.get $i
		            i32.mul               ;; dy
		            global.get $player_dy
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 8        ;; dw
		            i32.const 8        
		            i32.const 4         ;; scale
		            i32.const 0         ;; flip_x
		            i32.const 0         ;; flip_y
		            call $render_image
		        end

		        ;; heart
		        i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x0C ;; heart
	            i32.eq
		        if
					;;
				    i32.const 473856     ;; mem_addr
				    i32.const 64
				    i32.const 0 ;; button_00_f2
				    i32.mul
				    i32.add
					;;
		            i32.const 0xFF0000FF
		            i32.const 0xFF00FFFF
		            i32.const 0xFFFFFFFF
		            i32.const 32
		            local.get $j          ;; dx
		            i32.mul
		            global.get $player_dx
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 32
		            local.get $i
		            i32.mul               ;; dy
		            global.get $player_dy
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 8        ;; dw
		            i32.const 8        
		            i32.const 4         ;; scale
		            i32.const 0         ;; flip_x
		            i32.const 0         ;; flip_y
		            call $render_image
		        end

		        ;; tree
		        i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x0D ;; button_00_f2
	            i32.eq
		        if
					;;
				    i32.const 473856     ;; mem_addr
				    i32.const 64
				    i32.const 0x0D ;; tree
				    i32.mul
				    i32.add
					;;
					i32.const 0xFF008000
					i32.const 0xFF00FF00
		            i32.const 0xFFFFFFFF
		            i32.const 32
		            local.get $j          ;; dx
		            i32.mul
		            global.get $player_dx
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 32
		            local.get $i
		            i32.mul               ;; dy
		            global.get $player_dy
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 8        ;; dw
		            i32.const 8        ;; dh
		            i32.const 4         ;; scale
		            i32.const 0         ;; flip_x
		            i32.const 0         ;; flip_y
		            call $render_image
		        end

		        ;; water_wall
		        i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x0E ;; water_wall
	            i32.eq
		        if
					global.get $power_mode
					i32.const 3
					i32.eq
					if
						;;
					    i32.const 473856     ;; mem_addr
					    i32.const 64
					    i32.const 0x0E ;; water_wall
					    i32.mul
					    i32.add
						;;
						i32.const 0xFFFF0000
						i32.const 0xFFFF0000
			            i32.const 0xFFFF0000
			            i32.const 32
			            local.get $j          ;; dx
			            i32.mul
			            global.get $player_dx
			            i32.sub
			            global.get $cam_xy   ;; 144
			            i32.add
			            i32.const 32
			            local.get $i
			            i32.mul               ;; dy
			            global.get $player_dy
			            i32.sub
			            global.get $cam_xy   ;; 144
			            i32.add
			            i32.const 8        ;; dw
			            i32.const 8        ;; dh
			            i32.const 4         ;; scale
			            i32.const 0         ;; flip_x
			            i32.const 0         ;; flip_y
			            call $render_image
					end
		        end

		        ;; lumy_blue_arrow_up
		        i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x0F ;; water_wall
	            i32.eq
		        if
					global.get $power_mode
					i32.const 3
					i32.eq
					if
						;;
					    i32.const 473856     ;; mem_addr
					    i32.const 64
					    i32.const 0x09       ;; lumy_blue_arrow_up
					    i32.mul
					    i32.add
						;;
						i32.const 0xFFFF0000
						i32.const 0xFFFF0000
			            i32.const 0xFFFF0000
			            i32.const 32
			            local.get $j          ;; dx
			            i32.mul
			            global.get $player_dx
			            i32.sub
			            global.get $cam_xy   ;; 144
			            i32.add
			            i32.const 32
			            local.get $i
			            i32.mul               ;; dy
			            global.get $player_dy
			            i32.sub
			            global.get $cam_xy   ;; 144
			            i32.add
			            i32.const 8        ;; dw
			            i32.const 8        ;; dh
			            i32.const 4         ;; scale
			            i32.const 0         ;; flip_x
			            i32.const 0         ;; flip_y
			            call $render_image
					end
		        end

		        ;; lumy_blue_arrow_down
		        i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x10 ;; water_wall
	            i32.eq
		        if
					global.get $power_mode
					i32.const 3
					i32.eq
					if
						;;
					    i32.const 473856     ;; mem_addr
					    i32.const 64
					    i32.const 0x09       ;; lumy_blue_arrow_up
					    i32.mul
					    i32.add
						;;
						i32.const 0xFFFF0000
						i32.const 0xFFFF0000
			            i32.const 0xFFFF0000
			            i32.const 32
			            local.get $j          ;; dx
			            i32.mul
			            global.get $player_dx
			            i32.sub
			            global.get $cam_xy   ;; 144
			            i32.add
			            i32.const 32
			            local.get $i
			            i32.mul               ;; dy
			            global.get $player_dy
			            i32.sub
			            global.get $cam_xy   ;; 144
			            i32.add
			            i32.const 8        ;; dw
			            i32.const 8        ;; dh
			            i32.const 4         ;; scale
			            i32.const 0         ;; flip_x
			            i32.const 1         ;; flip_y
			            call $render_image
					end
		        end

		        ;; special_tree
		        i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x11 ;; button_00_f2
	            i32.eq
		        if
					;;
				    i32.const 473856     ;; mem_addr
				    i32.const 64
				    i32.const 0x0D ;; tree
				    i32.mul
				    i32.add
					;;
					i32.const 0xFF008000
					i32.const 0xFF00FF00
		            i32.const 0xFFFFFFFF
		            i32.const 32
		            local.get $j          ;; dx
		            i32.mul
		            global.get $player_dx
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 32
		            local.get $i
		            i32.mul               ;; dy
		            global.get $player_dy
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 8        ;; dw
		            i32.const 8        ;; dh
		            i32.const 4         ;; scale
		            i32.const 0         ;; flip_x
		            i32.const 0         ;; flip_y
		            call $render_image
		        end

		        ;; burnt_tree
		        i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x12 ;; button_00_f2
	            i32.eq
		        if
					;;
				    i32.const 473856     ;; mem_addr
				    i32.const 64
				    i32.const 0x0D ;; tree
				    i32.mul
				    i32.add
					;;
					i32.const 0xFF0040FF
					i32.const 0xFF0080FF
		            i32.const 0xFF202020
		            i32.const 32
		            local.get $j          ;; dx
		            i32.mul
		            global.get $player_dx
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 32
		            local.get $i
		            i32.mul               ;; dy
		            global.get $player_dy
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 8        ;; dw
		            i32.const 8        ;; dh
		            i32.const 4         ;; scale
		            i32.const 0         ;; flip_x
		            i32.const 0         ;; flip_y
		            call $render_image
		        end

				;; special_tree_b
		        i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x13 ;; button_00_f2
	            i32.eq
		        if
					;;
				    i32.const 473856     ;; mem_addr
				    i32.const 64
				    i32.const 0x0D ;; tree
				    i32.mul
				    i32.add
					;;
					i32.const 0xFF008000
					i32.const 0xFF00FF00
		            i32.const 0xFFFFFFFF
		            i32.const 32
		            local.get $j          ;; dx
		            i32.mul
		            global.get $player_dx
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 32
		            local.get $i
		            i32.mul               ;; dy
		            global.get $player_dy
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 8        ;; dw
		            i32.const 8        ;; dh
		            i32.const 4         ;; scale
		            i32.const 0         ;; flip_x
		            i32.const 0         ;; flip_y
		            call $render_image
		        end

				;; special_tree_c
		        i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x14 ;; button_00_f2
	            i32.eq
		        if
					;;
				    i32.const 473856     ;; mem_addr
				    i32.const 64
				    i32.const 0x0D ;; tree
				    i32.mul
				    i32.add
					;;
					i32.const 0xFF008000
					i32.const 0xFF00FF00
		            i32.const 0xFFFFFFFF
		            i32.const 32
		            local.get $j          ;; dx
		            i32.mul
		            global.get $player_dx
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 32
		            local.get $i
		            i32.mul               ;; dy
		            global.get $player_dy
		            i32.sub
		            global.get $cam_xy   ;; 144
		            i32.add
		            i32.const 8        ;; dw
		            i32.const 8        ;; dh
		            i32.const 4         ;; scale
		            i32.const 0         ;; flip_x
		            i32.const 0         ;; flip_y
		            call $render_image
		        end
		        
	            ;; increment_j
	            local.get $j ;; tile_x
	            i32.const 1
	            i32.add
	            local.tee $j
	            i32.const 40
	            i32.lt_u
	            br_if $loop_j
	        end
	        local.get $i ;; tile_y
	        i32.const 1
	        i32.add
	        local.tee $i
	        i32.const 40
	        i32.lt_u
	        br_if $loop_i
	    end
	)

	(func $render_player
		;; player_32x32x6p_192
		i32.const 476184     ;; timer_256
		i32.load8_u
		i32.const 64         ;; cycle length (2 frames * 32 frames each)
		i32.rem_u            ;; timer % 64
		i32.const 32
		i32.lt_u
		if (result i32)
			global.get $player_dir
			i32.const 3
			i32.eq
			if (result i32)
				i32.const 467200 ;; mem_addr
				i32.const 2
				i32.const 2048			
				i32.mul
				i32.add
			else
				i32.const 467200 ;; mem_addr
				global.get $player_dir
				i32.const 2048			
				i32.mul
				i32.add
			end
		else
			global.get $player_dir
			i32.const 3
			i32.eq
			if (result i32)
				i32.const 468224 ;; mem_addr
				i32.const 2
				i32.const 2048			
				i32.mul
				i32.add
			else
				i32.const 468224 ;; mem_addr
				global.get $player_dir
				i32.const 2048			
				i32.mul
				i32.add
			end
		end
		global.get $power_mode
		i32.const 0
		i32.eq
		if (result i32 i32 i32)
			i32.const 0xFF808080 ;; clr_00
			i32.const 0xFF9090FF ;; clr_01
			i32.const 0xFFFFFFFF ;; clr_02
		else
			global.get $power_mode
			i32.const 1
			i32.eq
			if (result i32 i32 i32)
				i32.const 0xFF008000 ;; clr_00
				i32.const 0xFF000000 ;; clr_01
				call $sine
				i32.const 8
				i32.shl
				i32.or
				i32.const 0xFFE0FFE0 ;; clr_02
			else
				global.get $power_mode
				i32.const 2
				i32.eq
				if (result i32 i32 i32)
					i32.const 0xFF000080 ;; clr_00
					call $sine
					i32.const 0
					i32.shl
					i32.or
					i32.const 0xFF0000FF ;; clr_01
					call $sine
					i32.const 8
					i32.shl
					i32.or
					i32.const 0xFF00FFFF ;; clr_02
				else
					i32.const 0xFF802020 ;; clr_00
					call $sine
					i32.const 0
					i32.shl
					i32.or
					call $sine
					i32.const 8
					i32.shl
					i32.or
					i32.const 0xFFFF0000 ;; clr_01
					i32.const 0xFFFFE0E0 ;; clr_02
					call $sine
					i32.const 0
					i32.shl
					i32.or
					call $sine
					i32.const 8
					i32.shl
					i32.or
				end
			end
		end
		global.get $cam_xy   ;; 144
		global.get $cam_xy   ;; 144
		i32.const 32         ;; dw
		i32.const 32         ;; dh
		i32.const 1          ;; scale
		global.get $player_dir
		i32.const 1
		i32.eq
		if (result i32)
			i32.const 476184 ;; timer_256
			i32.load8_u
			i32.const 128              
			i32.rem_u               
			i32.const 64
			i32.lt_u
			if (result i32)
				i32.const 1
			else
				i32.const 0
			end
		else
			global.get $player_dir
			i32.const 2
			i32.eq
			if (result i32)
				i32.const 1          ;; flip_x
			else
				i32.const 0          ;; flip_x
			end
		end
		i32.const 0          ;; flip_y
		call $render_image	
	)

	(func $render_pointer
		(param $dx     i32)
		(param $dy00   i32)
		(param $dy01   i32)
		(param $flip_x i32)
		;; pointer
		i32.const 476184 ;; timer_256
		i32.load8_u
		i32.const 64              ;; cycle length (2 frames * 32 frames each)
		i32.rem_u                 ;; timer % 64
		i32.const 32
		i32.lt_u
		if (result i32)
			i32.const 456704     ;; mem_addr pointer_f0
		else
			i32.const 456960     ;; mem_addr pointer_f1
		end
		i32.const 0xFF000000 ;; clr_00
		i32.const 0xFF000000 ;;
		i32.const 0xFF
		call $sine
		i32.sub
		i32.const 0
		i32.shl              ;; shift to red channel
		i32.or               ;; combine with base color
		call $sine
		i32.const 8
		i32.shl              ;; shift to green channel
		i32.or               ;; combine with base color
		i32.const 0xFFFFFFFF ;; clr_02
		local.get $dx        ;; dx
		i32.const 476191 ;; mem_addr pointer_option
		i32.load8_u
		i32.const 1
		i32.lt_u
		if (result i32)
			local.get $dy00  ;; dy00
		else
			local.get $dy01  ;; dy01
		end
		i32.const 16         ;; dw
		i32.const 16         ;; dh
		i32.const 2          ;; scale
		local.get $flip_x    ;; flip_x
		i32.const 0          ;; flip_y
		call $render_image
	)

	(func $render_rect 
	    (param $clr_00 i32)
	    (param $dx     i32) (param $dy i32)
	    (param $dw     i32) (param $dh i32)
	    (local $x      i32) (local $y  i32)
	    (local $pos_x  i32) (local $pos_y i32)
	    loop $loop_y
	        ;; Calculate actual Y position
	        local.get $dy
	        local.get $y
	        i32.add
	        local.set $pos_y
	        ;; Check if Y is in bounds
	        local.get $pos_y
	        i32.const 0
	        i32.ge_s
	        local.get $pos_y
	        i32.const 320
	        i32.lt_s
	        i32.and
	        if
	            i32.const 0
	            local.set $x
	            loop $loop_x
	                ;; Calculate actual X position
	                local.get $dx
	                local.get $x
	                i32.add
	                local.set $pos_x
	                ;; Check if X is in bounds
	                local.get $pos_x
	                i32.const 0
	                i32.ge_s
	                local.get $pos_x
	                i32.const 320
	                i32.lt_s
	                i32.and
	                if
	                    ;; Write pixel
	                    local.get $pos_y
	                    i32.const 320
	                    i32.mul
	                    local.get $pos_x
	                    i32.add
	                    i32.const 2
	                    i32.shl
	                    local.get $clr_00
	                    i32.store
	                end 
	                local.get $x
	                i32.const 1
	                i32.add
	                local.tee $x
	                local.get $dw
	                i32.lt_u
	                br_if $loop_x
	            end
	        end    
	        local.get $y
	        i32.const 1
	        i32.add
	        local.tee $y
	        local.get $dh
	        i32.lt_u
	        br_if $loop_y
	    end
	)

	(func $render_rgb_orb
		(param $type i32)
		(param $dx i32)
		(param $dy i32)
		i32.const 473600      ;;
		local.get $type
		i32.const 0
		i32.eq
		if (result i32 i32)
	        i32.const 0xFF008000
	        i32.const 0xFF90FF90
			else
			local.get $type
			i32.const 1
			i32.eq
			if (result i32 i32)
		        i32.const 0xFF0000FF
		        i32.const 0xFF9090FF
           else
				i32.const 0xFFFF0000
				i32.const 0xFFFF9090
           end
        end
		i32.const 0xFFFFFFFF
		local.get $dx         ;;
		i32.const 32          ;;
		i32.mul               ;; dx
		global.get $player_dx ;;
		i32.sub               ;;
		global.get $cam_xy    ;; 144
		i32.add               ;;
		local.get $dy         ;;
		i32.const 32          ;;
		i32.mul               ;; dy
		global.get $player_dy ;;
		i32.sub               ;;
		global.get $cam_xy    ;; 144
		i32.add               ;;
		i32.const 16          ;; dw
		i32.const 16          ;; dh
		i32.const 2           ;; scale
		i32.const 0           ;; flip_x
		i32.const 0           ;; flip_y
		call $render_image
	)
	
	(func $render_shooters (local $i i32) (local $slot i32) (local $type i32)
	    i32.const 0
	    local.set $i
	    loop $loop_i
	        i32.const 477808
	        local.get $i
	        i32.const 12
	        i32.mul
	        i32.add
	        local.tee $slot
	        i32.load8_u                    ;; exist?
	        i32.const 0
	        i32.ne
	        if
	            ;; --- img first, then colors pushed on top ---
	            i32.const 473600           ;; $img  rgb_orb_16x16
	            local.get $slot
	            i32.load8_u offset=1       ;; type
	            local.set $type            ;; FIX: was local.tee $type

	            ;; ---- inline color selection: each branch yields 3 i32 ----
	            local.get $type
	            i32.const 0
	            i32.eq
	            if (result i32 i32 i32)
	                i32.const 0xFFC0C0C0   ;; clr_00
	                i32.const 0xFFE0E0E0   ;; clr_01
	                i32.const 0xFFFFFFFF   ;; clr_02
	            else
	                local.get $type
	                i32.const 1
	                i32.eq
	                if (result i32 i32 i32)
	                    i32.const 0xFF008000
	                    i32.const 0xFF90FF90
	                    i32.const 0xFFFFFFFF
	                else
	                    local.get $type
	                    i32.const 2
	                    i32.eq
	                    if (result i32 i32 i32)
	                        i32.const 0xFF0000FF
	                        i32.const 0xFF9090FF
	                        i32.const 0xFFFFFFFF
	                    else
	                        i32.const 0xFFFF0000
	                        i32.const 0xFFFF9090
	                        i32.const 0xFFFFFFFF
	                    end
	                end
	            end

	            ;; ---- dx/dy from world coords ----
	            local.get $slot
	            i32.load16_u offset=4       ;; proj dx
	            global.get $player_dx
	            i32.sub
	            global.get $cam_xy
	            i32.add                    ;; screen dx
	            local.get $slot
	            i32.load16_u offset=6       ;; proj dy
	            global.get $player_dy
	            i32.sub
	            global.get $cam_xy
	            i32.add                    ;; screen dy
	            i32.const 16                ;; dw
	            i32.const 16                ;; dh
	            i32.const 2                 ;; scale
	            i32.const 0                 ;; flip_x
	            i32.const 0                 ;; flip_y
	            call $render_image

	            ;; ---- optional bright core ----
	            i32.const 0xFFFFFFFF
	            local.get $slot
	            i32.load16_u offset=4
	            global.get $player_dx
	            i32.sub
	            global.get $cam_xy
	            i32.add
	            i32.const 12
	            i32.add
	            local.get $slot
	            i32.load16_u offset=6
	            global.get $player_dy
	            i32.sub
	            global.get $cam_xy
	            i32.add
	            i32.const 12
	            i32.add
	            i32.const 8
	            i32.const 8
	            call $render_rect
	        end
	        local.get $i
	        i32.const 1
	        i32.add
	        local.tee $i
	        i32.const 4
	        i32.lt_u
	        br_if $loop_i
	    end
	)

	(func $update_player_shooters (local $i i32) (local $slot i32) (local $type i32)
	    ;; only on a fresh K press with no cooldown
	    i32.const 476178 ;; key_k
	    i32.load8_u
	    i32.const 1
	    i32.eq
	    i32.const 476183 ;; cooldown_k
	    i32.load8_u
	    i32.const 0
	    i32.eq
	    i32.and
	    if
	        i32.const 0
	        local.set $i
	        block $spawned
	            loop $find_slot
	                ;; slot addr = 477808 + i*12
	                i32.const 477808
	                local.get $i
	                i32.const 12
	                i32.mul
	                i32.add
	                local.tee $slot
	                i32.load8_u                 ;; exist?
	                i32.const 0
	                i32.eq
	                if
	                    ;; exist = 1
	                    local.get $slot
	                    i32.const 1
	                    i32.store8
	                    ;; type = power_mode
	                    local.get $slot
	                    global.get $power_mode
	                    i32.store8 offset=1
	                    ;; direction = player_dir
	                    local.get $slot
	                    global.get $player_dir
	                    i32.store8 offset=2

	                    ;; dx: spawn at player's x, nudged along the travel axis
	                    ;;   RIGHT (3) → +16
	                    ;;   LEFT  (2) → -16 (wraps to large u16, harmless since
	                    ;;                    render_image's bounds check skips
	                    ;;                    it, and the next frame's cull clears it)
	                    ;;   UP/DOWN   → 0 (centered horizontally)
	                    local.get $slot
	                    global.get $player_dx
	                    global.get $player_dir
	                    i32.const 3
	                    i32.eq
	                    if (result i32)
	                        i32.const 16
	                    else
	                        global.get $player_dir
	                        i32.const 2
	                        i32.eq
	                        if (result i32)
	                            i32.const -16
	                        else
	                            i32.const 0
	                        end
	                    end
	                    i32.add
	                    i32.store16 offset=4

	                    ;; dy: spawn at player's y, nudged along the travel axis
	                    ;;   DOWN (1) → +16
	                    ;;   UP   (0) → -16
	                    ;;   LEFT/RIGHT → 0 (centered vertically)
	                    local.get $slot
	                    global.get $player_dy
	                    global.get $player_dir
	                    i32.const 1
	                    i32.eq
	                    if (result i32)
	                        i32.const 16
	                    else
	                        global.get $player_dir
	                        i32.const 0
	                        i32.eq
	                        if (result i32)
	                            i32.const -16
	                        else
	                            i32.const 0
	                        end
	                    end
	                    i32.add
	                    i32.store16 offset=6

	                    ;; cooldown so holding K doesn't spam
	                    i32.const 476183 ;; cooldown_k
	                    i32.const 12
	                    i32.store8
	                    i32.const 1
	                    call $sfx
	                    br $spawned
	                end
	                local.get $i
	                i32.const 1
	                i32.add
	                local.tee $i
	                i32.const 4
	                i32.lt_u
	                br_if $find_slot
	            end
	        end
	    end

	    ;; --- move + cull all live projectiles ---
	    i32.const 0
	    local.set $i
	    loop $update
	        i32.const 477808
	        local.get $i
	        i32.const 12
	        i32.mul
	        i32.add
	        local.tee $slot
	        i32.load8_u                    ;; exist
	        i32.const 0
	        i32.ne
	        if
	            ;; dir
	            local.get $slot
	            i32.load8_u offset=2
	            i32.const 0
	            i32.eq
	            if
	                ;; UP → dy -= 4
	                local.get $slot
	                local.get $slot
	                i32.load16_u offset=6
	                i32.const 4
	                i32.sub
	                i32.store16 offset=6
	            else
	                local.get $slot
	                i32.load8_u offset=2
	                i32.const 1
	                i32.eq
	                if
	                    ;; DOWN → dy += 4
	                    local.get $slot
	                    local.get $slot
	                    i32.load16_u offset=6
	                    i32.const 4
	                    i32.add
	                    i32.store16 offset=6
	                else
	                    local.get $slot
	                    i32.load8_u offset=2
	                    i32.const 2
	                    i32.eq
	                    if
	                        ;; LEFT → dx -= 4
	                        local.get $slot
	                        local.get $slot
	                        i32.load16_u offset=4
	                        i32.const 4
	                        i32.sub
	                        i32.store16 offset=4
	                    else
	                        ;; RIGHT → dx += 4
	                        local.get $slot
	                        local.get $slot
	                        i32.load16_u offset=4
	                        i32.const 4
	                        i32.add
	                        i32.store16 offset=4
	                    end
	                end
	            end

	            ;; cull if outside the 1280x1280 world bounds.
	            ;; NOTE: load16_u is unsigned, so a projectile that went
	            ;; negative (dx -= 4 past 0) wraps to a huge u16 and is
	            ;; caught by the upper-bound check.
	            local.get $slot
	            i32.load16_u offset=4       ;; dx
	            i32.const 1280
	            i32.gt_u
	            local.get $slot
	            i32.load16_u offset=6       ;; dy
	            i32.const 1280
	            i32.gt_u
	            i32.or
	            if
	                local.get $slot
	                i32.const 0
	                i32.store8
	            else
	                ;; in bounds → check for solid tile collision.
	                ;; tile index = tile_y * 40 + tile_x, where tile coords
	                ;; come from the projectile center (dx+16, dy+16) / 32.
	                local.get $slot
	                i32.load16_u offset=4       ;; dx
	                i32.const 16
	                i32.add
	                i32.const 32
	                i32.div_u                   ;; tile_x
	                local.get $slot
	                i32.load16_u offset=6       ;; dy
	                i32.const 16
	                i32.add
	                i32.const 32
	                i32.div_u                   ;; tile_y
	                i32.const 40
	                i32.mul
	                i32.add
	                i32.const 476192            ;; mem_addr game_map
	                i32.add
	                i32.load8_u                 ;; tile id
	                local.set $type
	                local.get $type
	                i32.const 1
	                i32.eq                      ;; wall
	                local.get $type
	                i32.const 2
	                i32.eq                      ;; cloud
	                i32.or
	                local.get $type
	                i32.const 8
	                i32.eq                      ;; rainbow cloud
	                i32.or
	                local.get $type
	                i32.const 0x0E
	                i32.eq                      ;; water_wall
	                i32.or
	                if
	                    local.get $slot
	                    i32.const 0
	                    i32.store8
	                end
	            end
	        end

	        local.get $i
	        i32.const 1
	        i32.add
	        local.tee $i
	        i32.const 4
	        i32.lt_u
	        br_if $update
	    end
	)
	
	(func $update_power_mode (local $tries i32)
	    ;; only act on a fresh J press
	    i32.const 476177 ;; key_j
	    i32.load8_u
	    i32.const 1
	    i32.eq
	    i32.const 476182 ;; cooldown_j
	    i32.load8_u
	    i32.const 0
	    i32.eq
	    i32.and
	    if
	        i32.const 0
	        local.set $tries
	        block $done_power
	            loop $loop_power
	                ;; advance power_mode by 1, wrap at 4
	                global.get $power_mode
	                i32.const 1
	                i32.add
	                i32.const 4
	                i32.rem_u
	                global.set $power_mode

	                ;; is the candidate mode unlocked?
	                ;; mode 0 = base power (always unlocked)
	                ;; modes 1..3 = power_01/02/03 at 476188/476189/476190
	                global.get $power_mode
	                i32.const 0
	                i32.eq
	                if (result i32)
	                    i32.const 1
	                else
	                    global.get $power_mode
	                    i32.const 476187
	                    i32.add
	                    i32.load8_u
	                end
	                br_if $done_power

	                ;; not unlocked — try again (max 4 total attempts)
	                local.get $tries
	                i32.const 1
	                i32.add
	                local.tee $tries
	                i32.const 4
	                i32.lt_u
	                br_if $loop_power
	            end
	        end
	        i32.const 476182 ;; cooldown_j
	        i32.const 16
	        i32.store8
	        i32.const 1
	        call $sfx
	    end
	)

	(func $scene_title (local $clr_set_00 i32)
		i32.const 476160     ;; mem_addr rdm_clr_00
		i32.load
		local.set $clr_set_00
		;; background
		i32.const 0xFF101010 ;; clr_abgr
		call $render_bg
		;; game_title
		i32.const 409600      ;; mem_addr title_288x160
		local.get $clr_set_00 ;; color_abgr_00
		i32.const 0xFF808080  ;; color_abgr_01
		i32.const 0xFFFFFFFF  ;; color_abgr_02
		i32.const 16          ;; dx
		i32.const 16          ;; dy
		i32.const 288         ;; dw
		i32.const 64          ;; dh
		i32.const 1           ;; scale
		i32.const 0           ;; flip_x
		i32.const 0           ;; flip_y
		call $render_image
		;; title_lumy_96x104 (457216) (916764)
		i32.const 457216      ;; mem_addr
		i32.const 0xFF101010  ;; color_abgr_00
		local.get $clr_set_00 ;; color_abgr_00
		i32.const 0xFFFFFFFF  ;; color_abgr_02
		i32.const 32          ;; dx
		i32.const 168         ;; dy
		i32.const 96          ;; dw
		i32.const 104         ;; dh
		i32.const 1           ;; scale
		i32.const 0           ;; flip_x
		i32.const 0           ;; flip_y
		call $render_image

		i32.const 502000     ;; mem_addr_word
		i32.const 7          ;; letter count
		i32.const 476168     ;; mem_addr rdm_clr_02
		i32.load             ;; clr_00
		i32.const 0xFFFFFFFF ;; clr_02
		i32.const 16         ;; dx
		i32.const 108        ;; dy
		i32.const 2          ;; scale
		call $render_word
		
		;; start
		i32.const 501838     ;; mem_addr word
		i32.const 5          ;; letter count
		i32.const 476168     ;; mem_addr rdm_clr_02
		i32.load             ;; clr_00
		i32.const 0xFFFFFFFF ;; clr_02
		i32.const 220        ;; dx
		i32.const 200        ;; dy
		i32.const 2          ;; scale
		call $render_word

		;; about
		i32.const 501843     ;; mem_addr word
		i32.const 5          ;; letter count
		i32.const 476168     ;; mem_addr rdm_clr_02
		i32.load             ;; clr_00
		i32.const 0xFFFFFFFF ;; clr_02
		i32.const 220        ;; x
		i32.const 236        ;; y
		i32.const 2          ;; scale
		call $render_word
		;; Keys: WSAD JK
		i32.const 501881     ;; mem_addr word
		i32.const 13         ;; letter count
		i32.const 476164     ;; mem_addr rdm_clr_01
		i32.load             ;; clr_00
		i32.const 0xFFFFFFFF ;; clr_02
		i32.const 16         ;; dx
		i32.const 288        ;; dy
		i32.const 1          ;; scale
		call $render_word

		i32.const 188
		i32.const 200
		i32.const 236
		i32.const 0
		call $render_pointer

		;; update	
		;; keyK was pressed
		i32.const 476178 ;; mem_addr keyK
		i32.load8_u
		i32.const 1
		i32.eq
		i32.const 476183 ;; cooldown_k
		i32.load8_u
		i32.const 0
		i32.eq
		i32.and
		if
			i32.const 476191 ;; mem_addr pointer_choice
			i32.load8_u
			i32.const 0
			i32.eq
			if
				i32.const 476185 ;; mem_addr scene
				i32.const 1      ;;
				i32.store8       ;; scene_game
				i32.const 0      ;;
				call $sfm        ;; play music
			else
				i32.const 476185 ;; mem_addr scene
				i32.const 2      ;;
				i32.store8       ;; scene_about
				i32.const 476183 ;; cooldown_k
				i32.const 32     ;;
				i32.store8       ;; set cooldown_k to 32
				i32.const 0
				call $sfx
			end
		else
			i32.const 476176 ;; mem_addr UDLR
			i32.load8_u
			i32.const 0
			i32.eq
			if
				i32.const 476181 ;; cooldown_wsad
				i32.const 0      ;; end the cooldown_timer
				i32.store8
			else
				;; update from inputs
				;; maybe in the future allow more choices
				i32.const 476176 ;; mem_addr UDLR
				i32.load8_u
				i32.const 0
				i32.ne
				;;
				i32.const 476181 ;; cooldown_wsad
				i32.load8_u
				i32.const 0
				i32.eq
				;;
				i32.and
				if
					i32.const 476191 ;; mem_addr pointer_choice
					i32.load8_u
					i32.const 0
					i32.eq
					if
						i32.const 476191 ;; mem_addr pointer_choice
						i32.const 1
						i32.store8
					else
						i32.const 476191 ;; mem_addr pointer_choice
						i32.const 0
						i32.store8
					end
					i32.const 476181 ;; cooldown_wsad
					i32.const 32     ;;
					i32.store8       ;; set cooldown
					i32.const 0      ;;
					call $sfx        ;; play sound
				end
			end
		end
	)

	(func $render_word
		(param $mem_addr     i32)
		(param $letter_count i32)
		(param $clr_00       i32)
		(param $clr_02       i32)
		(param $x            i32)
		(param $y            i32)
		(param $scale        i32)
		(local $i            i32)
		loop $loop_i
			local.get $mem_addr
			local.get $i
			i32.add
			i32.load8_u          ;; ndx
			i32.const 48
			i32.lt_u
			if
				local.get $mem_addr
				local.get $i
				i32.add
				i32.load8_u          ;; ndx
				local.get $clr_00    ;; clr_00
				local.get $clr_02    ;; clr_02
				local.get $x         
				local.get $i
				i32.const 8
				local.get $scale
				i32.mul
				i32.mul
				i32.add              ;; dx
				local.get $y         ;; dy
				local.get $scale     ;; scale
				call $render_char
			end
			local.get $i
			i32.const 1
			i32.add
			local.tee $i
			local.get $letter_count
			i32.lt_u
			br_if $loop_i
		end
	)
	
	(func $scene_game (local $i i32) (local $j i32)
	    i32.const 0xFFFFC0C0
	    call $render_bg

		i32.const 0xFF3E91C8  ;; clr_abgr ;; maybe brown
		i32.const 32         ;;
        global.get $player_dx ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dx
        i32.const 352         ;;
        global.get $player_dy ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dy
        i32.const 288         ;; dw
        i32.const 288         ;; dh
		call $render_rect

		i32.const 0xFF3E91C8  ;; clr_abgr ;; maybe brown
		i32.const 32         ;;
        global.get $player_dx ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dx
        i32.const 640         ;;
        global.get $player_dy ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dy
        i32.const 256         ;; dw
        i32.const 608         ;; dh
		call $render_rect

		i32.const 0xFF3E91C8  ;; clr_abgr ;; maybe brown
		i32.const 32         ;;
        global.get $player_dx ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dx
        i32.const 640         ;;
        global.get $player_dy ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dy
        i32.const 256         ;; dw
        i32.const 608         ;; dh
		call $render_rect

		i32.const 0xFFA0A0FF  ;; clr_abgr red
		i32.const 640         ;;
        global.get $player_dx ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dx
        i32.const 32         ;;
        global.get $player_dy ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dy
        i32.const 608         ;; dw
        i32.const 608         ;; dh
		call $render_rect

		i32.const 0xFF800080  ;; clr_abgr ;; purp
		i32.const 960         ;;
        global.get $player_dx ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dx
        i32.const 640         ;;
        global.get $player_dy ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dy
        i32.const 288         ;; dw
        i32.const 608         ;; dh
		call $render_rect

		i32.const 0xFF100000  ;; blue_water
		i32.const 320         ;;
        global.get $player_dx ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dx
        i32.const 640         ;;
        global.get $player_dy ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dy
        i32.const 608         ;; dw
        i32.const 608         ;; dh
		call $render_rect

	    i32.const 473856      ;; mem_addr
	    i32.const 64          
	    i32.const 8           ;; check_board
	    i32.mul
	    i32.add
		i32.const 0xFF3E91C8  ;; clr_abgr ;; maybe brown
	    i32.const 0xFFFFC0C0
		i32.const 0xFF3E91C8  ;; clr_abgr ;; maybe brown
		i32.const 320         ;;
        global.get $player_dx ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dx
        i32.const 448         ;;
        global.get $player_dy ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dy
        i32.const 8          ;; dw
        i32.const 8          ;; dh
		i32.const 4           ;; scale
		i32.const 0           ;; flip_x
		i32.const 0           ;; flip_y
		call $render_image
	    i32.const 473856      ;; mem_addr
	    i32.const 64          
	    i32.const 8           ;; check_board
	    i32.mul
	    i32.add
		i32.const 0xFF3E91C8  ;; clr_abgr ;; maybe brown
	    i32.const 0xFFFFC0C0
		i32.const 0xFF3E91C8  ;; clr_abgr ;; maybe brown
		i32.const 320         ;;
        global.get $player_dx ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dx
        i32.const 480         ;;
        global.get $player_dy ;;
        i32.sub               ;;
        global.get $cam_xy    ;;
        i32.add               ;; dy
        i32.const 8          ;; dw
        i32.const 8          ;; dh
		i32.const 4           ;; scale
		i32.const 0           ;; flip_x
		i32.const 0           ;; flip_y
		call $render_image

	    call $render_map
		call $render_shooters
	    call $render_player
		call $render_hud

	    ;; update
	    i32.const 476176 ;; key_wsad
	    i32.load8_u
	    i32.const 1
	    i32.eq
	    if
	        global.get $player_dy
	        i32.const 4
	        i32.sub
	        global.set $player_dy
	        i32.const 0
	        global.set $player_dir
	    end
	    i32.const 476176 ;; key_wsad
	    i32.load8_u
	    i32.const 2
	    i32.eq
	    if
	        global.get $player_dy
	        i32.const 4
	        i32.add
	        global.set $player_dy
	        i32.const 1
	        global.set $player_dir
	    end
	    i32.const 476176 ;; key_wsad
	    i32.load8_u
	    i32.const 3
	    i32.eq
	    if
	        global.get $player_dx
	        i32.const 4
	        i32.sub
	        global.set $player_dx
	        i32.const 2
	        global.set $player_dir
	    end
	    i32.const 476176 ;; key_wsad
	    i32.load8_u
	    i32.const 4
	    i32.eq
	    if
	        global.get $player_dx
	        i32.const 4
	        i32.add
	        global.set $player_dx
	        i32.const 3
	        global.set $player_dir
	    end
		;; key j
		call $update_power_mode
		;; key k
		call $update_player_shooters

	    ;; update_map
	    i32.const 0
	    local.set $i ;; tile_y
	    loop $loop_k
	        i32.const 0
	        local.set $j ;; tile_x
	        loop $loop_l
	            i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 1
	            i32.eq

	            i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 2
	            i32.eq
	            i32.or

	            i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 8 ;; rainbow_cloud
	            i32.eq
	            i32.or

	            i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x0E ;; water_wall
	            i32.eq
	            i32.or
	            if
	                ;; check col with player
	                global.get $player_dx
	                i32.const 32
	                i32.add
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u

	                global.get $player_dx
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and

	                global.get $player_dy
	                i32.const 32
	                i32.add
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                i32.and

	                global.get $player_dy
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                if
	                    global.get $player_dir
	                    i32.const 0  ;; UP
	                    i32.eq
	                    if
	                        global.get $player_dy
	                        i32.const 4
	                        i32.add   ;; Push DOWN (reverse of UP)
	                        global.set $player_dy
	                    else						
	                        global.get $player_dir
	                        i32.const 1  ;; DOWN
	                        i32.eq
	                        if
	                            global.get $player_dy
	                            i32.const 4
	                            i32.sub   ;; Push UP (reverse of DOWN)
	                            global.set $player_dy
	                        else
	                            global.get $player_dir
	                            i32.const 2  ;; LEFT
	                            i32.eq
	                            if
	                                global.get $player_dx
	                                i32.const 4
	                                i32.add   ;; Push RIGHT (reverse of LEFT)
	                                global.set $player_dx
	                            else
	                                global.get $player_dir
	                                i32.const 3  ;; RIGHT
	                                i32.eq
	                                if
	                                    global.get $player_dx
	                                    i32.const 4
	                                    i32.sub   ;; Push LEFT (reverse of RIGHT)
	                                    global.set $player_dx
	                                end
	                            end
	                        end
	                    end						
	                end					
		         end

				;; rgb_orb_green
				i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 4 ;; rgb_orb_green
	            i32.eq
	            if
	                ;; check col with player
	                global.get $player_dx
	                i32.const 32
	                i32.add
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                global.get $player_dx
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                global.get $player_dy
	                i32.const 32
	                i32.add
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                i32.and
	                global.get $player_dy
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                if
			            i32.const 476192 ;; mem_addr game_map
			            local.get $i ;; tile_y
			            i32.const 40
			            i32.mul
			            local.get $j ;; tile_x
			            i32.add
			            i32.add
						i32.const 0
						i32.store8
						;; update orb count
						global.get $rgb_orbs
						i32.const 1
						i32.add
						global.set $rgb_orbs
						;; unlock lumy_g
						i32.const 476188 ;; mem_addr powers
						i32.const 1
						i32.store8
					end
				end

				;; rgb_orb_red
				i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 5 ;; rgb_orb_red
	            i32.eq
	            if
	                ;; check col with player
	                global.get $player_dx
	                i32.const 32
	                i32.add
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                global.get $player_dx
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                global.get $player_dy
	                i32.const 32
	                i32.add
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                i32.and
	                global.get $player_dy
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                if
			            i32.const 476192 ;; mem_addr game_map
			            local.get $i ;; tile_y
			            i32.const 40
			            i32.mul
			            local.get $j ;; tile_x
			            i32.add
			            i32.add
						i32.const 0
						i32.store8
						;; update orb count
						global.get $rgb_orbs
						i32.const 1
						i32.add
						global.set $rgb_orbs
						;; unlock lumy_r
						i32.const 476189 ;; mem_addr powers
						i32.const 1
						i32.store8
					end
				end
				;; rgb_orb_blue
				i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 6 ;; rgb_orb_blue
	            i32.eq
	            if
	                ;; check col with player
	                global.get $player_dx
	                i32.const 32
	                i32.add
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                global.get $player_dx
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                global.get $player_dy
	                i32.const 32
	                i32.add
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                i32.and
	                global.get $player_dy
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                if
			            i32.const 476192 ;; mem_addr game_map
			            local.get $i ;; tile_y
			            i32.const 40
			            i32.mul
			            local.get $j ;; tile_x
			            i32.add
			            i32.add
						i32.const 0
						i32.store8
						;; update orb count
						global.get $rgb_orbs
						i32.const 1
						i32.add
						global.set $rgb_orbs
						;; unlock lumy_b
						i32.const 476190 ;; mem_addr powers_b
						i32.const 1
						i32.store8
					end
				end
				;; map_set
				i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 9 ;; rgb_orb_green
	            i32.eq
	            if
	                ;; check col with player
	                global.get $player_dx
	                i32.const 32
	                i32.add
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                global.get $player_dx
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                global.get $player_dy
	                i32.const 32
	                i32.add
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                i32.and
	                global.get $player_dy
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                if
			            i32.const 476192 ;; mem_addr game_map
			            local.get $i ;; tile_y
			            i32.const 40
			            i32.mul
			            local.get $j ;; tile_x
			            i32.add
			            i32.add
						i32.const 0
						i32.store8
						i32.const 1
						global.set $has_map
					end
				end

				;; button_00
				i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x0A ;; rgb_orb_green
	            i32.eq
	            if
	                ;; check col with player
	                global.get $player_dx
	                i32.const 32
	                i32.add
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                global.get $player_dx
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                global.get $player_dy
	                i32.const 32
	                i32.add
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                i32.and
	                global.get $player_dy
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                if
			            i32.const 476192 ;; mem_addr game_map
			            local.get $i ;; tile_y
			            i32.const 40
			            i32.mul
			            local.get $j ;; tile_x
			            i32.add
			            i32.add
						i32.const 0x0B
						i32.store8
						;; todo: add logic to remove bottom blocks
						i32.const 476192
						i32.const 774
						i32.add
						i32.const 0
						i32.store16
					end
				end

				;; heart
				i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x0C ;; heart
	            i32.eq
	            if
	                ;; check col with player
	                global.get $player_dx
	                i32.const 32
	                i32.add
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                global.get $player_dx
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                global.get $player_dy
	                i32.const 32
	                i32.add
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                i32.and
	                global.get $player_dy
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                if
			            i32.const 476192 ;; mem_addr game_map
			            local.get $i ;; tile_y
			            i32.const 40
			            i32.mul
			            local.get $j ;; tile_x
			            i32.add
			            i32.add
						i32.const 0x00
						i32.store8
						global.get $hearts
						i32.const 1
						i32.add
						global.set $hearts
					end
				end

				;; tree
				i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x0D ;; special_tree
	            i32.eq
	            if
	                ;; check col with player
	                global.get $player_dx
	                i32.const 32
	                i32.add
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                global.get $player_dx
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                global.get $player_dy
	                i32.const 32
	                i32.add
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                i32.and
	                global.get $player_dy
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
					global.get $power_mode
					i32.const 2
					i32.eq
					i32.and
	                if
			            i32.const 476192 ;; mem_addr game_map
			            local.get $i ;; tile_y
			            i32.const 40
			            i32.mul
			            local.get $j ;; tile_x
			            i32.add
			            i32.add
						i32.const 0x12 ;; burnt_tree
						i32.store8
					end
				end

				;; special_tree
				i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x11 ;; special_tree
	            i32.eq
	            if
	                ;; check col with player
	                global.get $player_dx
	                i32.const 32
	                i32.add
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                global.get $player_dx
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                global.get $player_dy
	                i32.const 32
	                i32.add
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                i32.and
	                global.get $player_dy
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                if
			            i32.const 476192 ;; mem_addr game_map
			            local.get $i ;; tile_y
			            i32.const 40
			            i32.mul
			            local.get $j ;; tile_x
			            i32.add
			            i32.add
						i32.const 0x12 ;; burnt_tree
						i32.store8
						;; reveal heart
						i32.const 476192 ;; mem_addr game_map
						i32.const 488
						i32.add
						i32.const 0x0C
						i32.store8
					end
				end

				;; burnt tree
				i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x12 ;; burnt_tree
	            i32.eq
	            if
	                ;; check col with player
	                global.get $player_dx
	                i32.const 32
	                i32.add
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                global.get $player_dx
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                global.get $player_dy
	                i32.const 32
	                i32.add
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                i32.and
	                global.get $player_dy
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
					global.get $power_mode
					i32.const 1
					i32.eq
					i32.and
	                if
			            i32.const 476192 ;; mem_addr game_map
			            local.get $i ;; tile_y
			            i32.const 40
			            i32.mul
			            local.get $j ;; tile_x
			            i32.add
			            i32.add
						i32.const 0x0D ;; tree
						i32.store8
					end
				end

				;; special_tree_b
				i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x13 ;; special_tree_b
	            i32.eq
	            if
	                ;; check col with player
	                global.get $player_dx
	                i32.const 32
	                i32.add
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                global.get $player_dx
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                global.get $player_dy
	                i32.const 32
	                i32.add
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                i32.and
	                global.get $player_dy
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                if
			            i32.const 476192 ;; mem_addr game_map
			            local.get $i ;; tile_y
			            i32.const 40
			            i32.mul
			            local.get $j ;; tile_x
			            i32.add
			            i32.add
						i32.const 0x0D ;; tree
						i32.store8
						;; update special trees touched counter
						global.get $special_trees_touched
						i32.const 1
						i32.add
						global.set $special_trees_touched
						global.get $special_trees_touched
						;; reveal rgb_orb_green if touched 4 special trees
						i32.const 4
						i32.ge_u
						if
							i32.const 476192 ;; mem_addr game_map
							i32.const 524
							i32.add
							i32.const 0x04
							i32.store8
						end
					end
				end

				;; special_tree_c
				i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x14 ;; special_tree_c
	            i32.eq
	            if
	                ;; check col with player
	                global.get $player_dx
	                i32.const 32
	                i32.add
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                global.get $player_dx
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                global.get $player_dy
	                i32.const 32
	                i32.add
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                i32.and
	                global.get $player_dy
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
					global.get $power_mode
					i32.const 2
					i32.eq
					i32.and
	                if
			            i32.const 476192 ;; mem_addr game_map
			            local.get $i ;; tile_y
			            i32.const 40
			            i32.mul
			            local.get $j ;; tile_x
			            i32.add
			            i32.add
						i32.const 0x12 ;; burnt_tree
						i32.store8
						;; update brunt counter
						global.get $special_trees_burned
						i32.const 1
						i32.add
						global.set $special_trees_burned
						global.get $special_trees_burned
						i32.const 25
						i32.ge_u
						if
							;; reveal heart
							i32.const 476192 ;; mem_addr game_map
							i32.const 229
							i32.add
							i32.const 0x0C
							i32.store8
						end
					end
				end

				;; exit
				i32.const 476192 ;; mem_addr game_map
	            local.get $i ;; tile_y
	            i32.const 40
	            i32.mul
	            local.get $j ;; tile_x
	            i32.add
	            i32.add
	            i32.load8_u
	            i32.const 0x17 
	            i32.eq
	            if
	                ;; check col with player
	                global.get $player_dx
	                i32.const 32
	                i32.add
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                global.get $player_dx
	                local.get $j
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                global.get $player_dy
	                i32.const 32
	                i32.add
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.gt_s    ;; changed from gt_u
	                i32.and
	                global.get $player_dy
	                local.get $i
	                i32.const 32
	                i32.mul
	                i32.const 32
	                i32.add
	                i32.lt_s    ;; changed from lt_u
	                i32.and
	                if
						i32.const 476185 ;; mem_addr
						i32.const 0x03
						i32.store8
					end
				end

	            ;; increment_j
	            local.get $j ;; tile_x
	            i32.const 1
	            i32.add
	            local.tee $j
	            i32.const 40
	            i32.lt_u
	            br_if $loop_l
	        end
	        local.get $i ;; tile_y
	        i32.const 1
	        i32.add
	        local.tee $i
	        i32.const 40
	        i32.lt_u
	        br_if $loop_k
	    end
		;; if have all orbs
		global.get $rgb_orbs
		i32.const 3
		i32.ge_u
		if
			i32.const 0
			global.set $rgb_orbs
			i32.const 476606
			i32.const 0
			i32.store16
		end
	)

	(func $scene_about
	    i32.const 0xFF202080
	    call $render_bg

	    i32.const 457216     ;; mem_addr
	    i32.const 0xFF202080 ;; clr_00
	    i32.const 0xFF808080 ;; clr_01
	    i32.const 0xFF000020 ;; clr_02
	    i32.const 72         ;; dx
	    i32.const 72         ;; dy
	    i32.const 96         ;; dw
	    i32.const 104        ;; dh
	    i32.const 4          ;; scale
	    i32.const 1          ;; flip_x
	    i32.const 0          ;; flip_y
	    call $render_image

	    i32.const 0          ;; dx
	    i32.const 0          ;; dy
	    i32.const 0          ;; dy
	    i32.const 1          ;; flip_x
		call $render_pointer

	    ;; "about"
	    i32.const 501843     ;; mem_addr — was 501838
	    i32.const 5
	    i32.const 0xFFFFFFFF
	    i32.const 0xFF000000
	    i32.const 32
	    i32.const 0
	    i32.const 2
	    call $render_word

	    ;; "this game was made by "
	    i32.const 501848 ;; mem_addr
	    i32.const 22
	    i32.const 0xFFFFFFFF
	    i32.const 0xFF000000
	    i32.const 32
	    i32.const 36
	    i32.const 1
	    call $render_word

	    ;; "kenny fully"
	    i32.const 501870 ;; mem_addr
	    i32.const 11
	    i32.const 0xFF00FF00
	    i32.const 0xFF000000
	    i32.const 208
	    i32.const 36
	    i32.const 1
	    call $render_word

	    ;; "for js13k2026.Please enjoy the mini "
	    i32.const 501894 ;; mem_addr — was 501881
	    i32.const 35
	    i32.const 0xFFFFFFFF
	    i32.const 0xFF000000
	    i32.const 32
	    i32.const 56
	    i32.const 1
	    call $render_word

	    ;; "adventure."
	    i32.const 501929 ;; mem_addr — was 501916
	    i32.const 10
	    i32.const 0xFFFFFFFF
	    i32.const 0xFF000000
	    i32.const 32
	    i32.const 76
	    i32.const 1
	    call $render_word

	    ;; "press K to go back "
	    i32.const 501939 ;; mem_addr — was 501926
	    i32.const 18
	    i32.const 0xFFFFFFFF
	    i32.const 0xFF000000
	    i32.const 16
	    i32.const 288
	    i32.const 1
	    call $render_word

	    ;; update	
	    ;; keyK was pressed
	    i32.const 476178 ;; mem_addr K_button
	    i32.load8_u
	    i32.const 1
	    i32.eq
	    i32.const 476183 ;; cooldown_timer k
	    i32.load8_u
	    i32.const 0
	    i32.eq
	    i32.and
	    if
	        i32.const 476185 ;; mem_addr scene
	        i32.const 0      ;;
	        i32.store8       ;; go to scene_title
	        i32.const 476183 ;; mem_addr cooldown_k
	        i32.const 32
	        i32.store8
	        i32.const 0
	        call $sfx
	    end
	)	

	(func $scene_lose)

	(func $scene_win	
	    i32.const 0xFF000000
	    call $render_bg
		;; save
	    i32.const 501982
	    i32.const 18
	    i32.const 0xFFFFFFFF
	    i32.const 0xFF000000
	    i32.const 64
	    i32.const 160
	    i32.const 1
	    call $render_word
	)

	;; $sine:
	;;   i32.const 819224 → i32.const 476184 0
	(func $sine (result i32) (local $t i32)
	    i32.const 476184
	    i32.load8_u
	    i32.const 1
	    i32.shl              ;; t * 2
	    local.tee $t
	    i32.const 256
	    i32.lt_u
	    if (result i32)
	        local.get $t     ;; 0-254
	    else
	        i32.const 510
	        local.get $t
	        i32.sub          ;; 510 - t where t=256-510 → 254-0
	    end
	)	

	(func (export "gl") ;; game_loop
		(local $scene i32)
		i32.const 476185
		i32.load8_u
		local.tee $scene
		i32.const 0
		i32.eq
		if
			call $scene_title
		else
			local.get $scene
			i32.const 1
			i32.eq
			if
				call $scene_game
			else
				local.get $scene
				i32.const 2
				i32.eq
				if
					call $scene_about
				else
					local.get $scene
					i32.const 3
					i32.eq
					if
						call $scene_win
					else
						call $scene_lose
					end
				end
			end
		end
		
		;; keyJ
		i32.const 476177 ;; mem_addr keyJ
		i32.load8_u
		i32.const 0
		i32.eq
		if
			i32.const 476182 ;; cooldown_j
			i32.const 0
			i32.store8
		else
			i32.const 476182 ;; cooldown_j
			i32.load8_u
			i32.const 0
			i32.ne
			if
				i32.const 476182 ;; cooldown_j
				i32.const 476182 ;; cooldown_j
				i32.load8_u
				i32.const 1
				i32.sub
				i32.store8
			end
		end

		;; keyK
		i32.const 476178 ;; mem_addr keyK
		i32.load8_u
		i32.const 0
		i32.eq
		if
			i32.const 476183 ;; cooldown_k
			i32.const 0
			i32.store8
		else
			i32.const 476183 ;; cooldown_k
			i32.load8_u
			i32.const 0
			i32.ne
			if
				i32.const 476183  ;; cooldown_k
				i32.const 476183  ;; cooldown_k
				i32.load8_u
				i32.const 1
				i32.sub
				i32.store8
			end
		end

		;; update timer
		i32.const 476184 ;; timer_256
		i32.const 476184 ;; timer_256
		i32.load8_u
		i32.const 1
		i32.add
		i32.store8
	)

	;; init the app
	(start $init)

	;; rgba_vvb_320x320
	;; 409600 bytes
	;; (data (i32.const 0))

	;; decompressed_sprite_sheet_320x208
	;; 66560 bytes
	;; (data (i32.const 409600))
	
	(data (i32.const 476160)
		;; 12 bytes rdmclr
		"\FF\40\40\FF" ;; 476160 rdmclr00
		"\00\00\00\FF" ;; 476164 rdmclr01
		"\00\00\00\FF" ;; 476168 rdmclr02
		"\FF\00\00\FF" ;; 476172 rdmclr03
		;; 8 bytes inputs
		"\00"          ;; 476176 key_wsad
			           ;;        0x00 w
					   ;;        0x01 s
					   ;;        0x02 a
					   ;;        0x03 d
		"\00"          ;; 476177 key_j___
		"\00"          ;; 476178 key_k___
		"\00"          ;; 476179 reserved
		"\00"          ;; 476180 reserved
		"\00"          ;; 476181 cldnwsad
		"\00"          ;; 476182 cldn_j__
		"\00"          ;; 476183 cldn_k__
		;; 8 bytes global_values
		"\00"          ;; 476184 timer256 
		"\00"          ;; 476185 scene___
					   ;;        0x00 scene_title
				       ;;        0x01 scene_game
					   ;;        0x02 scene_about
				       ;;        0x03 scene_win
					   ;;        0x04 scene_lose
		"\00"          ;; 476186 subscene 
			           ;;        0x00 overworld_C3
		"\00"          ;; 476187 power_00
					   ;;        0x00 false
					   ;;        0x01 true
		"\00"          ;; 476188 power_01
					   ;;        0x00 false
					   ;;        0x01 true
		"\00"          ;; 476189 power_02
					   ;;        0x00 false
					   ;;        0x01 true
		"\00"          ;; 476190 power_03
					   ;;        0x00 false
					   ;;        0x01 true
		"\00"          ;; 476191 ptr_sel_
			           ;;        0x00 option_00
		               ;;        0x01 option_01

		;; 1600 bytes game_map
		;; 476192
		"\07\17\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02"
		"\17\17\00\00\00\00\00\00\00\00" "\02\00\00\00\02\0C\00\00\00\03" "\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\02"
		"\02\00\00\00\00\00\00\00\00\00" "\02\00\00\00\02\00\00\00\00\02" "\00\00\00\00\00\14\00\00\00\00" "\00\00\00\00\12\00\00\00\00\02"
		"\02\00\00\00\00\00\00\00\00\00" "\02\00\00\00\02\00\00\00\00\02" "\00\00\00\00\00\14\14\00\00\00" "\00\00\00\12\12\00\00\00\00\02"
		"\02\00\00\00\00\00\00\00\00\00" "\00\00\00\00\02\00\00\00\00\02" "\00\00\14\14\14\14\14\14\00\00" "\00\00\12\12\12\12\12\12\00\02"
		"\02\00\00\00\00\00\00\00\00\00" "\00\00\00\00\02\02\02\02\02\02" "\00\00\14\14\14\14\14\14\14\00" "\05\12\12\12\12\12\12\12\00\02"
		"\02\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02" "\00\00\14\14\14\14\14\14\00\00" "\00\00\12\12\12\12\12\12\00\02"
		"\02\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\14\14\00\00\00" "\00\00\00\12\12\00\00\00\00\02"
		"\02\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\14\00\00\00\00" "\00\00\00\00\12\00\00\00\00\02"
		"\02\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\02"
		
		"\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\08\08\02\02\02\02" "\00\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02"
		"\02\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02"
		"\02\00\13\00\00\00\00\0D\00\00" "\02\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02"
		"\02\00\00\00\00\00\00\00\0D\00" "\02\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02"
		"\02\00\0F\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02"
		"\02\00\00\00\00\00\00\00\10\00" "\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02"
		"\02\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02"
		"\02\00\0D\0D\00\00\00\00\13\00" "\02\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02"
		"\02\00\0D\0D\00\00\00\13\13\00" "\02\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\00" "\02\00\00\00\00\00\00\00\00\02"
		"\02\00\00\00\00\00\00\00\00\02" "\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02" "\02\00\00\00\00\00\00\00\00\02"

		"\02\0D\0D\0D\0D\0D\0D\0D\0D\02" "\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\0E\00\0C\02" "\0A\00\00\00\00\00\00\00\00\02"
		"\02\0D\0D\0D\0D\0D\0D\0D\0D\02" "\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\0E\00\00\02" "\00\00\00\00\00\00\00\00\00\02"
		"\02\0D\0D\0D\0D\0D\0D\0D\0D\02" "\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\0E\00\00\02" "\00\00\00\00\00\00\00\00\00\02"
		"\02\0D\0D\0D\0D\0D\0D\0D\0D\02" "\00\00\00\00\00\00\00\00\00\00" "\0E\0E\0E\0E\0E\0E\0E\00\00\02" "\00\00\00\00\00\00\00\00\00\02"
		"\02\0D\0D\0D\0D\0D\0D\0D\0D\02" "\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\02"
		"\02\0D\0D\0D\0D\0D\0D\0D\0D\02" "\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\02"
		"\02\0D\0D\0D\0D\0D\0D\0D\0D\02" "\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\02"
		"\02\0D\0D\0D\0D\0D\0D\0D\0D\02" "\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\02"
		"\02\0D\0D\0D\0D\0D\0D\0D\0D\02" "\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\02"
		"\02\0D\0D\0D\0D\0D\0D\0D\0D\02" "\00\00\00\00\00\00\0E\00\00\0E" "\0E\0E\0E\00\00\00\00\0E\0E\02" "\00\00\00\00\00\00\00\00\00\02"
		
		"\02\0D\0D\0D\0D\0D\0D\0D\0D\02" "\0E\0E\0E\0E\00\00\0E\00\00\0E" "\00\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\02"
		"\02\00\00\00\00\00\00\00\00\02" "\00\00\00\0E\00\00\0E\00\00\0E" "\00\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\02"
		"\02\00\0D\0D\0D\0D\0D\0D\00\02" "\00\0C\00\0E\00\00\0E\00\00\0E" "\00\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\02"
		"\02\00\00\00\00\00\00\00\00\02" "\00\00\00\0E\00\00\0E\00\00\0E" "\00\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\00\02"
		"\02\00\00\0D\0D\0D\0D\00\00\02" "\00\00\00\0E\00\00\0E\00\00\0E" "\00\00\00\00\00\00\00\00\00\02" "\00\00\00\00\00\00\00\00\09\02"
		"\02\00\00\00\00\00\00\00\00\02" "\00\00\00\0E\0E\0E\0E\00\00\0E" "\00\00\00\00\00\00\00\00\00\02" "\02\02\02\02\02\02\02\02\02\02"
		"\02\00\0D\0D\0D\0D\0D\0D\00\02" "\00\00\00\00\00\00\00\00\00\0E" "\00\00\00\00\00\00\00\00\00\03" "\00\00\00\00\00\00\00\00\00\02"
		"\02\00\00\00\00\10\00\00\00\02" "\00\00\00\00\00\00\00\00\00\0E" "\00\00\00\00\00\00\00\00\00\03" "\00\00\00\00\00\00\00\06\00\02"
		"\02\0D\0D\0D\0D\11\0D\0D\0D\02" "\00\00\00\00\00\00\00\00\00\0E" "\00\00\00\00\00\00\00\00\00\03" "\00\00\00\00\00\00\00\00\00\02"
		"\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02"
	)

	(data (i32.const 477792)
		"\FF\FF\FF\FF" ;; 477792 white
		"\80\FF\80\FF" ;; 477896 green
		"\FF\80\80\FF" ;; 477800 red
		"\80\80\FF\FF" ;; 477804 blue
		;; player shoot 00
		;; 477808
		"\00"          ;; exist
		"\00"          ;; type
		"\00"          ;; direction
		"\00"          ;; reserved
		"\00\00"       ;; dx
		"\00\00"       ;; dy
		;; player shoot 01
		;; 477816
		"\00"          ;; exist
		"\00"          ;; type
		"\00"          ;; direction
		"\00"          ;; reserved
		"\00\00"       ;; dx
		"\00\00"       ;; dy
		;; player shoot 02
		;; 477824
		"\00"          ;; exist
		"\00"          ;; type
		"\00"          ;; direction
		"\00"          ;; reserved
		"\00\00"       ;; dx
		"\00\00"       ;; dy
		;; player shoot 03
		;; 477832
		"\00"          ;; exist
		"\00"          ;; type
		"\00"          ;; direction
		"\00"          ;; reserved
		"\00\00"       ;; dx
		"\00\00"       ;; dy
		;; boss
		;; 477840
		"\0A"          ;; hp 10
		"\00"          ;; color_type
		               ;; 0x00 white
		               ;; 0x01 green
		               ;; 0x02 red
		               ;; 0x03 blue 
		"\00\00"       ;; dx between 0x2000 and 0x2001 (little endian)
		"\00\00"       ;; dy always  0x2000
	)

	(data (i32.const 482482)
		;; original: 18432 bytes → compressed: 5524 bytes 
		;; 482482 chinese_title_288x64
		"\11\00\02\01\B2\00\07\01\3C\00\08\01\1E\00\03\01\02\03\03\01\0E\00\07\01\6C\00\06\01\26\00\02\01\07\03\02\01\39\00\01\01\08\03\01\01\1C\00\01\01\03\03\02\01\03\03\01\01\0C\00\01\01\07\03\09\01\15\00\02\01\3B\00\04\01\0B\00\02\01\06\03\02\01\23\00\01\01\02\03\07\01\02\03\01\01\2A\00\05\01\08\00\01\01\01\03\08\01\01\03\01\01\1A\00\01\01\01\03\08\01\01\03\01\01\0A\00\01\01\01\03\07\01\09\03\01\01\11\00\03\01\02\03\03\01\36\00\02\01\04\03\02\01\08\00\01\01\02\03\06\01\02\03\01\01\21\00\01\01\01\03\0B\01\01\03\01\01\28\00\01\01\05\03\01\01\06\00\01\01\01\03\0A\01\01\03\01\01\18\00\01\01\01\03\0A\01\01\03\01\01\08\00\01\01\01\03\11\01\01\03\01\01\0F\00\01\01\03\03\02\01\03\03\01\01\2F\00\02\01\03\00\01\01\02\03\04\01\02\03\01\01\06\00\01\01\01\03\0A\01\01\03\01\01\20\00\01\01\01\03\0C\01\01\03\01\01\26\00\01\01\01\03\05\01\01\03\07\01\01\03\0B\01\01\03\01\01\16\00\01\01\01\03\0B\01\01\03\01\01\07\00\01\01\01\03\13\01\01\03\01\01\0D\00\01\01\01\03\08\01\01\03\01\01\2C\00\02\01\02\03\03\01\01\03\08\01\01\03\01\01\04\00\01\01\01\03\0C\01\01\03\01\01\20\00\01\01\01\03\0C\01\01\03\09\01\1C\00\01\01\01\03\07\01\06\03\02\01\02\03\09\01\01\03\01\01\16\00\01\01\01\03\0C\01\01\03\01\01\06\00\01\01\01\03\0B\01\01\03\08\01\01\03\01\01\0B\00\01\01\01\03\0A\01\01\03\01\01\2A\00\01\01\02\03\02\01\02\03\02\01\01\03\08\01\01\03\01\01\03\00\01\01\01\03\0C\01\01\03\01\01\20\00\01\01\01\03\0C\01\01\03\01\01\08\03\02\01\1A\00\01\01\01\03\0D\01\01\03\01\01\01\03\0A\01\01\03\01\01\17\00\01\01\02\03\0A\01\01\03\01\01\07\00\01\01\02\03\09\01\01\03\08\01\01\03\01\01\0A\00\01\01\01\03\0C\01\01\03\01\01\28\00\01\01\01\03\06\01\01\03\01\01\01\03\08\01\01\03\01\01\04\00\01\01\01\03\0B\01\01\03\01\01\1F\00\01\01\01\03\0D\01\02\03\08\01\02\03\01\01\19\00\01\01\01\03\0C\01\01\03\02\01\01\03\0A\01\01\03\01\01\18\00\01\01\01\03\0A\01\01\03\02\01\07\00\01\01\01\03\09\01\02\03\07\01\01\03\01\01\0A\00\01\01\01\03\0C\01\01\03\01\01\17\00\05\01\0B\00\01\01\01\03\08\01\02\03\09\01\01\03\01\01\04\00\01\01\01\03\0A\01\01\03\01\01\1F\00\01\01\01\03\19\01\01\03\01\01\18\00\01\01\01\03\0B\01\01\03\02\01\01\03\0A\01\01\03\01\01\16\00\02\01\01\00\01\01\01\03\0A\01\03\03\01\01\06\00\01\01\01\03\09\01\02\03\07\01\01\03\01\01\0B\00\01\01\02\03\0A\01\01\03\01\01\07\00\02\01\08\00\06\01\05\03\02\01\08\00\01\01\01\03\14\01\01\03\01\01\04\00\01\01\01\03\0A\01\01\03\01\01\1E\00\01\01\01\03\1B\01\01\03\01\01\17\00\01\01\01\03\0B\01\01\03\01\01\01\03\0A\01\02\03\03\01\13\00\01\01\02\03\02\01\01\03\0D\01\01\03\01\01\06\00\01\01\01\03\08\01\02\03\06\01\01\03\01\01\0D\00\01\01\01\03\0A\01\01\03\01\01\06\00\01\01\02\03\01\01\01\00\06\01\06\03\05\01\02\03\01\01\07\00\01\01\01\03\14\01\01\03\01\01\04\00\01\01\01\03\0A\01\01\03\01\01\1C\00\02\01\01\03\1D\01\01\03\01\01\16\00\01\01\01\03\0B\01\01\03\01\01\01\03\0C\01\03\03\01\01\11\00\01\01\01\03\02\01\03\03\0E\01\01\03\07\01\01\03\08\01\03\03\04\01\01\03\01\01\0F\00\01\01\01\03\09\01\01\03\01\01\05\00\01\01\01\03\02\01\01\03\01\01\06\03\0D\01\01\03\01\01\06\00\01\01\01\03\14\01\01\03\01\01\04\00\01\01\01\03\0A\01\01\03\01\01\1B\00\01\01\02\03\1E\01\01\03\01\01\13\00\05\01\01\03\09\01\03\03\10\01\01\03\01\01\0F\00\01\01\01\03\14\01\01\03\01\01\05\03\01\01\01\03\10\01\01\03\01\01\0E\00\01\01\01\03\09\01\01\03\01\01\04\00\01\01\01\03\03\01\02\03\13\01\01\03\01\01\07\00\01\01\02\03\11\01\01\03\01\01\05\00\01\01\01\03\0A\01\01\03\07\01\14\00\01\01\01\03\20\01\01\03\01\01\11\00\02\01\07\03\1C\01\01\03\01\01\0D\00\01\01\01\03\16\01\01\03\05\01\02\03\11\01\01\03\01\01\0D\00\01\01\01\03\09\01\01\03\03\01\01\00\01\01\01\03\1A\01\01\03\01\01\07\00\02\01\02\03\0F\01\01\03\01\01\05\00\01\01\01\03\0A\01\08\03\01\01\10\00\03\01\01\03\21\01\01\03\01\01\10\00\01\01\02\03\24\01\01\03\01\01\0C\00\01\01\01\03\2F\01\01\03\01\01\0D\00\01\01\01\03\09\01\04\03\02\01\01\03\1A\01\01\03\01\01\09\00\01\01\01\03\0E\01\01\03\08\01\01\03\12\01\01\03\01\01\0E\00\01\01\03\03\21\01\01\03\01\01\10\00\01\01\01\03\27\01\01\03\01\01\0B\00\01\01\01\03\2F\01\01\03\01\01\07\00\07\01\01\03\0D\01\02\03\1B\01\01\03\01\01\0A\00\01\01\01\03\0C\01\01\03\01\01\09\03\13\01\01\03\01\01\0C\00\01\01\01\03\16\01\02\03\0B\01\01\03\02\01\10\00\01\01\01\03\28\01\01\03\01\01\0A\00\01\01\01\03\2F\01\01\03\01\01\06\00\01\01\08\03\0E\01\01\03\1B\01\01\03\01\01\09\00\01\01\01\03\0C\01\01\03\01\01\01\03\1D\01\01\03\01\01\0A\00\01\01\01\03\11\01\07\03\0B\01\04\03\02\01\0E\00\01\01\01\03\28\01\01\03\01\01\0B\00\01\01\01\03\12\01\03\03\19\01\01\03\01\01\05\00\01\01\01\03\17\01\01\03\1A\01\01\03\01\01\09\00\01\01\01\03\0B\01\01\03\01\01\01\03\1F\01\01\03\01\01\08\00\01\01\01\03\10\01\02\03\05\01\01\03\10\01\02\03\02\01\0D\00\01\01\01\03\17\01\05\03\0B\01\01\03\01\01\0B\00\01\01\01\03\0F\01\03\03\02\01\01\03\18\01\01\03\01\01\05\00\01\01\01\03\33\01\01\03\01\01\08\00\01\01\01\03\0D\01\02\03\1F\01\01\03\01\01\08\00\01\01\01\03\0F\01\01\03\02\01\05\03\13\01\02\03\01\01\0C\00\01\01\01\03\17\01\05\03\0B\01\01\03\01\01\0C\00\01\01\02\03\03\01\01\03\09\01\06\03\11\01\04\03\01\01\02\03\01\01\06\00\01\01\01\03\32\01\01\03\01\01\07\00\02\01\01\03\0E\01\02\03\1F\01\01\03\01\01\08\00\01\01\01\03\0D\01\05\03\1A\01\01\03\01\01\0C\00\01\01\01\03\09\01\04\03\18\01\01\03\01\01\0C\00\01\01\01\03\02\01\04\03\0E\01\01\03\11\01\02\03\05\01\01\03\01\01\05\00\01\01\01\03\19\01\01\03\11\01\03\03\03\01\01\03\01\01\07\00\01\01\02\03\0F\01\02\03\1F\01\01\03\01\01\09\00\01\01\02\03\2A\01\01\03\01\01\0C\00\01\01\01\03\25\01\01\03\01\01\0B\00\01\01\01\03\01\01\01\03\02\01\03\03\17\01\02\03\08\01\01\03\06\01\01\03\01\01\05\00\01\01\01\03\18\01\02\03\10\01\01\03\01\01\01\03\02\01\01\03\01\01\07\00\01\01\01\03\11\01\02\03\1F\01\01\03\01\01\0A\00\02\01\03\03\28\01\01\03\01\01\0B\00\01\01\01\03\25\01\01\03\01\01\0A\00\01\01\01\03\03\01\02\03\1A\01\02\03\08\01\01\03\06\01\01\03\01\01\05\00\01\01\01\03\18\01\01\03\01\01\06\03\0A\01\01\03\02\01\02\03\01\01\07\00\01\01\01\03\13\01\01\03\13\01\02\03\0A\01\01\03\01\01\0C\00\01\01\01\03\2A\01\01\03\01\01\0A\00\01\01\01\03\25\01\01\03\01\01\09\00\01\01\01\03\20\01\02\03\08\01\01\03\06\01\01\03\01\01\05\00\01\01\01\03\0F\01\01\03\08\01\01\03\06\01\01\03\0A\01\01\03\01\01\01\00\02\01\08\00\01\01\01\03\13\01\01\03\09\01\01\03\09\01\02\03\0A\01\01\03\01\01\0C\00\01\01\01\03\2A\01\01\03\01\01\0A\00\01\01\01\03\18\01\02\03\0A\01\01\03\01\01\0A\00\01\01\01\03\20\01\02\03\0F\01\01\03\01\01\05\00\01\01\01\03\07\01\01\03\07\01\01\03\08\01\01\03\01\01\04\00\01\01\01\03\0A\01\01\03\01\01\0C\00\01\01\01\03\07\01\02\03\09\01\01\03\09\01\01\03\09\01\02\03\0A\01\01\03\01\01\0C\00\01\01\01\03\2A\01\01\03\01\01\0B\00\01\01\01\03\23\01\01\03\01\01\0A\00\01\01\01\03\20\01\02\03\0F\01\01\03\01\01\05\00\01\01\01\03\07\01\01\03\07\01\01\03\08\01\01\03\01\01\04\00\01\01\01\03\0A\01\01\03\01\01\0D\00\01\01\02\03\04\01\01\03\01\01\01\03\09\01\02\03\08\01\01\03\09\01\02\03\09\01\01\03\01\01\0E\00\01\01\01\03\18\01\05\03\0C\01\01\03\01\01\0B\00\01\01\01\03\09\01\03\03\17\01\01\03\01\01\0A\00\01\01\01\03\17\01\01\03\08\01\01\03\01\01\01\03\0D\01\01\03\01\01\06\00\01\01\01\03\07\01\01\03\07\01\01\03\08\01\01\03\01\01\04\00\01\01\01\03\0A\01\01\03\01\01\0E\00\02\01\04\03\02\01\01\03\09\01\02\03\08\01\01\03\09\01\02\03\09\01\01\03\01\01\0E\00\01\01\01\03\18\01\01\03\03\01\01\03\0C\01\01\03\01\01\0B\00\01\01\01\03\22\01\01\03\01\01\0B\00\01\01\01\03\15\01\03\03\08\01\01\03\01\01\01\03\0D\01\01\03\01\01\06\00\01\01\01\03\07\01\01\03\07\01\01\03\08\01\01\03\01\01\04\00\01\01\01\03\0A\01\01\03\01\01\10\00\05\01\01\03\0B\01\01\03\08\01\01\03\09\01\02\03\09\01\01\03\01\01\0E\00\01\01\01\03\0A\01\04\03\0A\01\05\03\0C\01\01\03\01\01\0B\00\01\01\01\03\22\01\01\03\01\01\0B\00\01\01\01\03\12\01\03\03\02\01\01\03\08\01\01\03\01\01\01\03\0D\01\01\03\01\01\06\00\01\01\01\03\07\01\01\03\07\01\01\03\07\01\01\03\01\01\05\00\01\01\01\03\0A\01\01\03\01\01\13\00\01\01\01\03\0C\01\01\03\08\01\01\03\09\01\01\03\0A\01\01\03\01\01\0E\00\01\01\01\03\0A\01\04\03\0E\01\01\03\0C\01\01\03\01\01\0B\00\01\01\01\03\22\01\01\03\04\01\09\00\01\01\01\03\12\01\03\03\01\01\01\03\08\01\01\03\01\01\01\03\0C\01\02\03\01\01\06\00\01\01\01\03\07\01\01\03\07\01\01\03\07\01\01\03\01\01\05\00\01\01\01\03\0A\01\01\03\01\01\13\00\01\01\01\03\0C\01\01\03\08\01\01\03\13\01\01\03\01\01\0E\00\01\01\01\03\2A\01\01\03\01\01\08\00\04\01\01\03\21\01\06\03\02\01\08\00\01\01\09\03\0C\01\02\03\08\01\02\03\0C\01\02\03\01\01\01\03\01\01\05\00\01\01\01\03\07\01\01\03\0F\01\01\03\01\01\05\00\01\01\01\03\0A\01\01\03\01\01\12\00\01\01\01\03\0D\01\01\03\1C\01\01\03\01\01\0E\00\01\01\01\03\2A\01\01\03\01\01\07\00\01\01\03\03\02\01\01\03\14\01\04\03\0E\01\02\03\01\01\08\00\01\01\01\03\05\01\02\03\0D\01\01\03\16\01\02\03\02\01\01\03\01\01\04\00\01\01\01\03\17\01\01\03\01\01\05\00\01\01\01\03\0A\01\01\03\01\01\11\00\01\01\01\03\0E\01\01\03\1C\01\01\03\01\01\0E\00\01\01\01\03\2A\01\01\03\01\01\06\00\01\01\01\03\03\01\01\03\02\01\01\03\09\01\06\03\18\01\01\03\01\01\06\00\01\01\01\03\07\01\01\03\23\01\01\03\01\01\01\03\02\01\01\03\01\01\04\00\01\01\01\03\17\01\01\03\01\01\05\00\01\01\01\03\0A\01\01\03\01\01\10\00\01\01\01\03\0F\01\01\03\1C\01\01\03\01\01\0E\00\01\01\01\03\2A\01\01\03\01\01\05\00\01\01\01\03\04\01\06\03\26\01\01\03\01\01\05\00\01\01\01\03\21\01\01\03\09\01\02\03\03\01\01\03\01\01\04\00\01\01\01\03\17\01\01\03\01\01\04\00\01\01\01\03\0B\01\01\03\01\01\0F\00\01\01\01\03\10\01\01\03\1C\01\01\03\01\01\0E\00\01\01\01\03\2A\01\01\03\01\01\04\00\01\01\01\03\31\01\01\03\01\01\06\00\01\01\01\03\20\01\01\03\0A\01\01\03\04\01\01\03\01\01\04\00\01\01\01\03\15\01\01\03\01\01\05\00\01\01\01\03\0B\01\01\03\01\01\0E\00\01\01\01\03\11\01\01\03\1B\01\01\03\01\01\0F\00\01\01\01\03\1C\01\02\03\0C\01\01\03\01\01\03\00\01\01\01\03\32\01\01\03\01\01\06\00\01\01\01\03\1F\01\01\03\10\01\01\03\01\01\04\00\01\01\01\03\15\01\01\03\01\01\05\00\01\01\01\03\0B\01\01\03\01\01\0C\00\02\01\01\03\12\01\01\03\1B\01\01\03\01\01\0F\00\01\01\01\03\19\01\03\03\01\01\01\03\0C\01\01\03\01\01\03\00\01\01\01\03\32\01\01\03\01\01\05\00\01\01\01\03\31\01\01\03\01\01\04\00\01\01\01\03\14\01\01\03\01\01\06\00\01\01\01\03\0B\01\01\03\01\01\0B\00\01\01\02\03\13\01\02\03\18\01\02\03\01\01\10\00\01\01\01\03\0B\01\04\03\0A\01\05\03\0C\01\01\03\01\01\03\00\01\01\01\03\32\01\01\03\01\01\05\00\01\01\01\03\10\01\05\03\1C\01\01\03\01\01\05\00\01\01\01\03\0E\01\01\03\03\01\02\03\01\01\06\00\01\01\01\03\0A\01\01\03\01\01\0B\00\01\01\01\03\15\01\02\03\11\01\03\03\03\01\02\03\02\01\10\00\01\01\01\03\0A\01\05\03\1B\01\01\03\01\01\03\00\01\01\01\03\31\01\01\03\01\01\06\00\01\01\01\03\10\01\01\03\03\01\01\03\1D\01\01\03\01\01\05\00\01\01\01\03\04\01\01\03\0E\01\01\03\01\01\05\00\01\01\01\03\0A\01\01\03\01\01\04\00\02\01\05\00\01\01\01\03\0A\01\01\03\0A\01\01\03\01\01\01\03\10\01\02\03\06\01\02\03\01\01\0E\00\01\01\01\03\2B\01\01\03\01\01\04\00\01\01\01\03\18\01\05\03\08\01\05\03\05\01\01\03\01\01\07\00\01\01\01\03\10\01\01\03\01\01\02\00\01\01\01\03\1C\01\01\03\01\01\06\00\01\01\05\03\0E\01\01\03\01\01\01\00\01\01\03\00\01\01\01\03\0A\01\01\03\05\01\02\03\02\01\04\00\01\01\01\03\08\01\02\03\0A\01\01\03\02\01\01\03\04\01\02\03\09\01\02\03\08\01\01\03\01\01\0D\00\01\01\01\03\2B\01\01\03\01\01\05\00\01\01\01\03\0E\01\07\03\11\01\01\03\01\01\01\03\02\01\03\03\01\01\07\00\01\01\01\03\11\01\01\03\04\01\01\03\0F\01\01\03\0C\01\01\03\01\01\07\00\04\01\01\03\08\01\01\03\06\01\01\03\01\01\01\03\01\01\02\00\01\01\01\03\0A\01\06\03\02\01\02\03\01\01\04\00\01\01\02\03\05\01\01\03\01\01\01\03\0A\01\01\03\03\01\04\03\01\01\01\03\09\01\02\03\09\01\01\03\01\01\0C\00\01\01\01\03\2B\01\01\03\01\01\06\00\01\01\02\03\25\01\01\03\01\01\02\03\03\01\08\00\01\01\01\03\12\01\06\03\04\01\03\03\06\01\01\03\01\01\01\03\0B\01\01\03\01\01\05\00\02\01\02\00\01\01\01\03\11\01\01\03\01\01\01\03\03\01\01\03\14\01\01\03\01\01\04\00\02\01\05\03\02\01\01\03\0A\01\01\03\01\01\02\03\05\01\01\03\09\01\03\03\09\01\01\03\01\01\0A\00\01\01\01\03\2C\01\01\03\01\01\07\00\02\01\04\03\22\01\01\03\02\01\0B\00\01\01\01\03\17\01\05\03\03\01\01\03\03\01\02\03\01\01\01\00\01\01\01\03\09\01\01\03\02\01\04\00\01\01\02\03\03\01\01\03\14\01\04\03\15\01\01\03\01\01\05\00\01\01\01\03\03\01\01\00\01\01\01\03\09\01\01\03\01\01\01\03\02\01\01\03\04\01\01\03\15\01\01\03\01\01\0A\00\01\01\01\03\2C\01\01\03\01\01\09\00\02\01\01\03\24\01\01\03\01\01\0A\00\01\01\01\03\1D\01\07\03\06\01\01\03\08\01\03\03\01\01\02\00\01\01\01\03\02\01\04\03\2E\01\01\03\01\01\03\00\01\01\01\03\01\01\02\03\02\01\01\03\0A\01\02\03\03\01\05\03\17\01\01\03\01\01\09\00\01\01\01\03\1E\01\02\03\0C\01\01\03\01\01\0A\00\01\01\01\03\24\01\01\03\01\01\09\00\02\01\01\03\22\01\0A\03\05\01\02\03\03\01\01\03\02\01\01\03\36\01\01\03\01\01\02\00\01\01\01\03\03\01\03\03\0A\01\01\03\20\01\01\03\01\01\08\00\01\01\01\03\1B\01\04\03\01\01\01\03\0C\01\01\03\01\01\0B\00\01\01\02\03\22\01\01\03\01\01\08\00\01\01\02\03\37\01\01\03\02\01\01\03\36\01\01\03\01\01\02\00\01\01\01\03\10\01\01\03\21\01\01\03\01\01\07\00\01\01\01\03\0C\01\05\03\0A\01\01\03\04\01\01\03\0C\01\01\03\01\01\0C\00\01\01\01\03\13\01\02\03\0D\01\01\03\01\01\07\00\01\01\01\03\0B\01\01\03\2D\01\01\03\01\01\01\03\37\01\01\03\01\01\02\00\01\01\01\03\32\01\01\03\01\01\06\00\01\01\01\03\0D\01\01\03\03\01\01\03\0A\01\01\03\04\01\01\03\0C\01\01\03\01\01\0C\00\01\01\01\03\0B\01\08\03\02\01\01\03\0C\01\01\03\01\01\07\00\01\01\01\03\0B\01\03\03\2A\01\01\03\02\01\01\03\37\01\01\03\01\01\03\00\01\01\01\03\31\01\01\03\01\01\05\00\01\01\01\03\0D\01\01\03\01\01\02\00\01\01\01\03\0A\01\05\03\0D\01\01\03\01\01\0C\00\01\01\01\03\0A\01\01\03\0A\01\01\03\0B\01\01\03\01\01\08\00\01\01\01\03\0A\01\01\03\03\01\02\03\28\01\01\03\02\01\01\03\12\01\01\03\24\01\01\03\01\01\03\00\01\01\01\03\0E\01\01\03\22\01\01\03\01\01\04\00\01\01\01\03\0E\01\01\03\01\01\02\00\01\01\01\03\1C\01\01\03\01\01\0C\00\01\01\01\03\0A\01\0B\03\0C\01\01\03\01\01\08\00\01\01\01\03\0A\01\01\03\01\01\02\00\02\01\02\03\25\01\01\03\01\01\01\00\01\01\01\03\11\01\01\03\01\01\01\03\23\01\01\03\01\01\03\00\01\01\01\03\0E\01\01\03\18\01\01\03\09\01\01\03\01\01\03\00\01\01\01\03\0E\01\01\03\01\01\03\00\01\01\01\03\0A\01\01\03\11\01\01\03\01\01\0D\00\01\01\01\03\1F\01\01\03\01\01\09\00\01\01\01\03\09\01\01\03\01\01\05\00\02\01\02\03\23\01\01\03\01\01\01\00\01\01\01\03\0F\01\02\03\01\01\01\00\01\01\03\03\1F\01\01\03\01\01\04\00\01\01\01\03\0E\01\01\03\15\01\04\03\09\01\01\03\01\01\03\00\01\01\01\03\0E\01\01\03\01\01\03\00\01\01\01\03\0A\01\01\03\11\01\01\03\01\01\0D\00\01\01\01\03\1F\01\01\03\01\01\09\00\01\01\01\03\09\01\01\03\01\01\07\00\02\01\02\03\20\01\01\03\01\01\03\00\01\01\01\03\0D\01\01\03\02\01\03\00\02\01\01\03\15\01\03\03\07\01\01\03\01\01\05\00\01\01\01\03\0C\01\02\03\12\01\03\03\03\01\01\03\08\01\01\03\01\01\04\00\01\01\01\03\0D\01\01\03\01\01\05\00\01\01\01\03\08\01\02\03\10\01\01\03\01\01\0E\00\01\01\01\03\1F\01\01\03\01\01\09\00\01\01\01\03\08\01\01\03\01\01\0A\00\02\01\03\03\1D\01\01\03\01\01\03\00\01\01\01\03\0B\01\02\03\01\01\07\00\01\01\01\03\0A\01\0A\03\03\01\01\03\04\01\02\03\01\01\06\00\01\01\01\03\0C\01\01\03\01\01\01\03\0E\01\03\03\03\01\02\00\01\01\01\03\08\01\01\03\01\01\05\00\01\01\01\03\0C\01\01\03\01\01\05\00\01\01\01\03\08\01\01\03\01\01\01\03\0F\01\01\03\01\01\0E\00\01\01\01\03\1F\01\01\03\01\01\0A\00\01\01\02\03\04\01\02\03\01\01\0D\00\03\01\03\03\19\01\01\03\01\01\05\00\01\01\01\03\08\01\02\03\02\01\09\00\01\01\0A\03\0A\01\02\00\01\01\01\03\03\01\01\03\02\01\08\00\01\01\01\03\0A\01\01\03\02\01\01\03\0B\01\03\03\03\01\05\00\01\01\01\03\07\01\01\03\01\01\07\00\01\01\01\03\0A\01\01\03\01\01\07\00\01\01\01\03\06\01\01\03\02\01\01\03\0E\01\01\03\01\01\0F\00\01\01\01\03\1F\01\01\03\01\01\0B\00\02\01\04\03\02\01\11\00\03\01\03\03\15\01\01\03\01\01\07\00\01\01\08\03\02\01\0C\00\0A\01\0C\00\01\01\01\03\01\01\02\03\01\01\0B\00\01\01\01\03\08\01\01\03\01\01\02\00\01\01\01\03\07\01\03\03\03\01\09\00\01\01\02\03\03\01\02\03\01\01\09\00\01\01\02\03\07\01\01\03\01\01\09\00\01\01\02\03\03\01\01\03\01\01\02\00\01\01\01\03\0D\01\01\03\01\01\10\00\01\01\01\03\1D\01\01\03\01\01\0E\00\04\01\16\00\03\01\03\03\11\01\01\03\01\01\09\00\08\01\25\00\01\01\01\03\02\01\0D\00\01\01\01\03\06\01\01\03\01\01\04\00\01\01\07\03\03\01\0D\00\02\01\03\03\02\01\0B\00\02\01\07\03\01\01\0B\00\02\01\03\03\01\01\04\00\01\01\01\03\0B\01\01\03\01\01\11\00\01\01\01\03\0F\01\08\03\05\01\01\03\01\01\2C\00\03\01\05\03\08\01\04\03\01\01\38\00\01\01\10\00\01\01\06\03\01\01\06\00\07\01\12\00\03\01\0F\00\07\01\0E\00\03\01\06\00\01\01\02\03\07\01\02\03\01\01\13\00\01\01\01\03\07\01\07\03\08\01\05\03\01\01\30\00\05\01\08\03\04\01\4B\00\06\01\51\00\02\01\07\03\02\01\15\00\01\01\02\03\03\01\02\03\07\01\08\00\05\01\36\00\08\01\A8\00\07\01\18\00\02\01\03\03\02\01\FF\00\1C\00\03\01\FF\00\FF\00\FF\00\FF\00\A7\00"

		;; original: 6144 bytes → compressed: 4814 bytes
		;; 488006 charset_8x16x48v
		"\02\00\04\03\03\00\01\03\04\01\01\03\02\00\01\03\04\01\01\03\01\00\01\03\06\01\02\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\06\01\02\03\06\01\02\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\01\03\01\00\02\03\02\00\02\03\02\00\05\03\02\00\01\03\05\01\01\03\01\00\01\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\05\01\01\03\01\00\01\03\05\01\01\03\01\00\01\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\05\01\01\03\02\00\05\03\05\00\04\03\03\00\01\03\04\01\01\03\01\00\01\03\05\01\02\03\06\01\02\03\04\01\02\03\01\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\04\01\02\03\01\00\01\03\06\01\01\03\01\00\01\03\05\01\01\03\02\00\01\03\04\01\01\03\03\00\04\03\02\00\05\03\02\00\01\03\05\01\01\03\01\00\01\03\06\01\02\03\02\01\01\03\03\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\01\03\03\01\02\03\06\01\02\03\05\01\01\03\02\00\05\03\04\00\04\03\03\00\01\03\04\01\01\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\02\03\03\01\03\03\01\00\01\03\03\01\03\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\02\03\03\01\03\03\01\00\01\03\03\01\03\03\01\00\01\03\06\01\02\03\06\01\01\03\01\00\01\03\04\01\01\03\03\00\04\03\04\00\05\03\02\00\01\03\05\01\02\03\06\01\02\03\06\01\02\03\06\01\02\03\03\01\03\03\01\00\01\03\03\01\03\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\02\03\03\01\03\03\01\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\04\00\03\03\06\00\03\03\04\00\01\03\03\01\01\03\02\00\01\03\05\01\01\03\01\00\01\03\02\01\02\03\01\01\01\03\01\00\01\03\02\01\02\03\01\01\01\03\01\00\01\03\02\01\01\03\01\00\01\03\02\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\04\03\01\00\01\03\02\01\01\03\03\01\02\03\02\01\01\03\03\01\02\03\02\01\02\03\01\01\01\03\01\00\01\03\05\01\01\03\02\00\01\03\03\01\01\03\04\00\03\03\04\00\02\03\02\00\02\03\01\00\01\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\06\01\02\03\06\01\02\03\06\01\02\03\06\01\02\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\01\03\01\00\02\03\02\00\02\03\02\00\06\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\02\03\02\01\02\03\03\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\03\00\02\03\02\01\02\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\06\03\02\00\06\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\03\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\02\00\02\03\03\01\01\03\01\00\01\03\05\01\01\03\01\00\01\03\05\01\01\03\01\00\01\03\04\01\01\03\03\00\04\03\04\00\02\03\02\00\02\03\01\00\01\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\01\03\03\01\02\03\06\01\02\03\05\01\01\03\01\00\01\03\04\01\01\03\02\00\01\03\04\01\01\03\02\00\01\03\05\01\01\03\01\00\01\03\06\01\02\03\02\01\01\03\03\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\01\03\01\00\02\03\02\00\02\03\02\00\03\03\04\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\03\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\06\03\02\00\01\03\04\00\01\03\01\00\01\03\01\01\01\03\02\00\01\03\01\01\02\03\01\01\01\03\02\00\01\03\01\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\06\01\02\03\06\01\02\03\06\01\02\03\01\01\01\03\02\01\01\03\01\01\02\03\01\01\01\03\02\01\01\03\01\01\02\03\01\01\01\03\02\01\01\03\01\01\02\03\01\01\04\03\01\01\02\03\01\01\01\03\02\00\01\03\01\01\01\03\01\00\01\03\04\00\01\03\02\00\02\03\02\00\02\03\01\00\01\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\03\01\01\03\02\01\02\03\03\01\01\03\02\01\02\03\06\01\02\03\06\01\02\03\06\01\02\03\06\01\02\03\02\01\01\03\03\01\02\03\02\01\01\03\03\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\01\03\01\00\02\03\02\00\02\03\03\00\04\03\03\00\01\03\04\01\01\03\01\00\01\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\01\03\01\00\01\03\04\01\01\03\03\00\04\03\03\00\05\03\02\00\01\03\05\01\01\03\01\00\01\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\05\01\01\03\01\00\01\03\03\01\02\03\02\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\04\00\03\03\06\00\04\03\03\00\01\03\04\01\01\03\01\00\01\03\06\01\02\03\02\01\03\03\01\01\02\03\02\01\01\03\01\00\01\03\01\01\02\03\02\01\01\03\01\00\01\03\01\01\02\03\02\01\01\03\01\00\01\03\01\01\02\03\02\01\01\03\01\00\01\03\01\01\02\03\02\01\03\03\01\01\02\03\06\01\01\03\01\00\01\03\04\01\01\03\03\00\02\03\01\01\02\03\04\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\04\00\03\03\02\00\05\03\02\00\01\03\05\01\01\03\01\00\01\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\06\01\02\03\05\01\01\03\01\00\01\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\01\03\01\00\02\03\02\00\02\03\03\00\04\03\03\00\01\03\04\01\01\03\01\00\01\03\06\01\02\03\06\01\02\03\03\01\01\03\02\01\02\03\03\01\03\03\01\00\01\03\04\01\01\03\03\00\01\03\04\01\01\03\02\00\01\03\04\01\01\03\03\00\01\03\04\01\01\03\01\00\03\03\03\01\02\03\02\01\01\03\03\01\02\03\06\01\02\03\06\01\01\03\01\00\01\03\04\01\01\03\03\00\04\03\03\00\06\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\02\03\02\01\02\03\03\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\05\00\02\03\04\00\02\03\02\00\02\03\01\00\01\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\06\01\01\03\01\00\01\03\04\01\01\03\03\00\04\03\03\00\02\03\02\00\02\03\01\00\01\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\01\03\01\00\01\03\04\01\01\03\02\00\01\03\04\01\01\03\03\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\05\00\02\03\04\00\01\03\04\00\01\03\01\00\01\03\01\01\01\03\02\00\01\03\01\01\02\03\01\01\04\03\01\01\02\03\01\01\01\03\02\01\01\03\01\01\02\03\01\01\01\03\02\01\01\03\01\01\02\03\01\01\01\03\02\01\01\03\01\01\02\03\06\01\02\03\06\01\02\03\06\01\02\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\01\01\01\03\02\00\01\03\01\01\02\03\01\01\01\03\02\00\01\03\01\01\01\03\01\00\01\03\04\00\01\03\02\00\02\03\02\00\02\03\01\00\01\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\01\03\01\00\01\03\04\01\01\03\03\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\03\00\01\03\04\01\01\03\01\00\01\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\01\03\01\00\02\03\02\00\02\03\02\00\02\03\02\00\02\03\01\00\01\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\06\01\01\03\01\00\01\03\04\01\01\03\02\00\01\03\04\01\01\03\03\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\05\00\02\03\04\00\06\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\03\03\03\01\01\03\03\00\01\03\03\01\01\03\02\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\02\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\02\00\01\03\03\01\01\03\03\00\01\03\03\01\03\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\06\03\02\00\06\03\01\00\01\03\06\01\02\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\06\01\01\03\01\00\06\03\04\00\02\03\05\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\05\00\02\03\04\00\06\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\04\03\02\01\01\03\04\00\01\03\02\01\01\03\01\00\04\03\02\01\02\03\06\01\02\03\06\01\02\03\02\01\04\03\01\00\01\03\02\01\01\03\04\00\01\03\02\01\04\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\06\03\02\00\06\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\03\03\03\01\01\03\01\00\03\03\03\01\02\03\06\01\02\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\03\03\03\01\01\03\01\00\03\03\03\01\02\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\06\03\02\00\02\03\02\00\02\03\01\00\01\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\06\01\01\03\01\00\03\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\03\00\01\03\03\01\01\03\04\00\03\03\02\00\06\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\02\03\02\01\04\03\01\00\01\03\02\01\01\03\04\00\01\03\02\01\04\03\01\00\01\03\06\01\02\03\06\01\01\03\01\00\04\03\02\01\01\03\04\00\01\03\02\01\01\03\01\00\04\03\02\01\02\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\06\03\02\00\06\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\02\03\02\01\04\03\01\00\01\03\02\01\01\03\04\00\01\03\02\01\04\03\01\00\01\03\06\01\02\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\06\03\02\00\06\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\04\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\05\00\02\03\02\00\06\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\06\03\02\00\06\03\01\00\01\03\06\01\02\03\06\01\02\03\06\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\02\01\02\03\06\01\02\03\06\01\01\03\01\00\04\03\02\01\01\03\04\00\01\03\02\01\01\03\01\00\04\03\02\01\02\03\06\01\02\03\06\01\02\03\06\01\01\03\01\00\06\03\62\00\02\03\05\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\05\00\02\03\06\00\02\03\05\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\05\00\02\03\05\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\05\00\02\03\06\00\05\03\02\00\01\03\05\01\01\03\01\00\01\03\06\01\02\03\06\01\01\03\01\00\03\03\03\01\01\03\02\00\02\03\03\01\01\03\01\00\01\03\05\01\02\03\05\01\01\03\01\00\01\03\04\01\01\03\02\00\01\03\02\01\02\03\03\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\05\00\02\03\05\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\05\00\02\03\46\00\01\03\06\00\01\03\01\01\01\03\05\00\01\03\01\01\01\03\06\00\01\03\01\01\01\03\05\00\01\03\01\01\01\03\04\00\01\03\01\01\01\03\05\00\01\03\01\01\01\03\06\00\01\03\07\00\01\03\06\00\01\03\01\01\01\03\05\00\01\03\01\01\01\03\05\00\01\03\01\01\01\03\05\00\01\03\01\01\01\03\06\00\01\03\58\00\01\03\02\00\01\03\03\00\01\03\01\01\02\03\01\01\01\03\02\00\01\03\01\01\02\03\01\01\01\03\02\00\01\03\01\01\02\03\01\01\01\03\02\00\01\03\01\01\02\03\01\01\01\03\03\00\01\03\02\00\01\03\95\00\02\03\05\00\01\03\02\01\01\03\03\00\02\03\02\01\02\03\01\00\01\03\06\01\02\03\06\01\01\03\01\00\02\03\02\01\02\03\03\00\01\03\02\01\01\03\05\00\02\03\54\00\06\03\01\00\01\03\06\01\02\03\06\01\01\03\01\00\06\03\52\00\02\03\02\00\02\03\01\00\01\03\02\01\02\03\02\01\02\03\06\01\01\03\01\00\01\03\04\01\01\03\02\00\01\03\04\01\01\03\01\00\01\03\06\01\02\03\02\01\02\03\02\01\01\03\01\00\02\03\02\00\02\03\34\00\02\03\05\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\03\00\06\03\01\00\01\03\06\01\02\03\06\01\01\03\01\00\06\03\03\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\05\00\02\03\0F\00\02\03\05\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\03\00\01\03\02\01\02\03\03\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\03\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\05\00\02\03\17\00\02\03\05\00\01\03\02\01\01\03\03\00\01\03\04\01\01\03\02\00\01\03\04\01\01\03\02\00\01\03\04\01\01\03\02\00\01\03\04\01\01\03\03\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\03\00\01\03\04\01\01\03\02\00\01\03\04\01\01\03\02\00\01\03\04\01\01\03\02\00\01\03\04\01\01\03\03\00\01\03\02\01\01\03\05\00\02\03\0B\00"

		;; original: 512 bytes → compressed: 212 bytes
		;; 492820 pointer_16x16x2f
		"\11\00\02\03\0E\00\04\03\0C\00\01\03\01\01\01\02\03\03\0A\00\01\03\01\02\01\01\02\02\03\03\08\00\01\03\02\02\01\01\03\02\03\03\06\00\01\03\03\02\01\01\04\02\03\03\04\00\01\03\0A\02\03\03\02\00\01\03\03\02\07\01\03\03\02\00\01\03\02\02\06\01\03\03\04\00\01\03\01\02\05\01\03\03\06\00\01\03\04\01\03\03\08\00\01\03\02\01\03\03\0A\00\04\03\0C\00\02\03\3F\00\02\03\0E\00\04\03\0C\00\01\03\01\01\01\02\03\03\0A\00\01\03\01\02\01\01\02\02\03\03\08\00\01\03\02\02\01\01\03\02\03\03\06\00\01\03\08\02\03\03\04\00\01\03\02\02\06\01\03\03\04\00\01\03\01\02\05\01\03\03\06\00\01\03\04\01\03\03\08\00\01\03\02\01\03\03\0A\00\04\03\0C\00\02\03\2C\00"

		;; original: 9984 bytes → compressed: 4036 bytes
		;; 493032 title_lumy_96x104
		"\65\00\01\01\5E\00\01\01\01\03\01\01\20\00\01\01\3C\00\01\01\02\03\01\01\1E\00\01\01\01\02\01\01\3B\00\01\01\03\03\01\01\1D\00\01\01\01\02\01\03\01\01\3A\00\01\01\04\03\01\01\1C\00\01\01\02\02\01\03\01\01\3A\00\01\01\04\03\01\01\1C\00\01\01\02\02\01\03\01\01\39\00\01\01\05\03\01\01\1B\00\01\01\03\02\01\03\01\01\34\00\01\01\04\00\01\01\05\03\02\01\17\00\01\01\01\00\01\01\03\02\01\03\01\01\33\00\01\01\01\03\02\01\02\00\01\01\07\03\01\01\15\00\01\01\01\02\01\01\01\00\01\01\02\02\02\03\01\01\32\00\01\01\03\03\02\01\01\00\01\01\07\03\01\01\14\00\01\01\01\02\01\03\03\01\02\02\02\03\01\01\32\00\01\01\04\03\01\01\01\00\01\01\07\03\02\01\12\00\01\01\02\02\02\03\01\01\03\02\02\03\01\01\2E\00\01\01\02\00\01\01\05\03\02\01\02\02\07\03\01\01\12\00\01\01\02\02\02\03\01\01\02\02\03\03\01\01\2C\00\01\01\01\03\01\01\02\00\01\01\07\03\02\02\07\03\02\01\11\00\01\01\02\02\02\03\01\01\01\02\04\03\01\01\2A\00\01\01\01\03\01\02\01\01\03\00\01\01\08\03\01\02\08\03\02\01\0F\00\02\01\02\02\02\03\01\01\02\02\03\03\01\01\28\00\01\01\01\03\01\02\01\01\05\00\01\01\08\03\02\02\08\03\02\01\0C\00\01\01\01\03\02\01\01\02\03\03\03\02\03\03\01\01\26\00\01\01\01\03\01\02\01\01\07\00\01\01\09\03\01\02\04\03\01\02\04\03\02\01\0A\00\01\01\01\02\01\03\02\01\01\02\03\03\02\02\04\03\01\01\18\00\01\01\06\00\01\01\04\00\01\01\01\03\02\02\01\01\08\00\02\01\08\03\02\02\03\03\02\02\04\03\02\01\08\00\01\01\02\02\01\03\01\01\02\02\03\03\02\02\04\03\02\01\15\00\01\01\01\03\01\01\04\00\01\01\01\03\01\01\02\00\01\01\03\03\01\01\06\00\03\01\02\00\02\01\07\03\02\02\04\03\01\02\05\03\02\01\07\00\01\01\02\02\01\03\02\01\02\02\02\03\02\02\05\03\01\01\13\00\01\01\02\03\01\01\03\00\01\01\02\03\01\01\01\00\01\01\01\03\02\02\01\01\06\00\01\01\03\03\02\01\04\02\07\03\03\02\02\03\01\02\06\03\02\01\06\00\01\01\02\02\02\03\03\02\02\03\02\02\05\03\02\01\0E\00\04\01\01\03\01\02\05\01\02\03\01\01\01\02\02\03\02\02\01\01\07\00\01\01\08\03\03\02\07\03\05\02\06\03\03\01\04\00\01\01\02\02\02\03\03\02\02\03\02\02\06\03\01\01\0B\00\02\01\02\02\01\01\01\03\01\02\01\03\01\01\02\02\02\03\03\01\01\02\01\03\02\02\01\01\09\00\01\01\09\03\03\02\05\03\01\02\03\03\03\02\07\03\02\01\03\00\01\01\02\02\02\03\04\02\02\03\02\02\05\03\02\01\08\00\01\01\01\02\01\03\02\02\01\01\01\03\01\02\01\03\01\01\03\02\02\03\01\01\02\03\02\02\01\01\0B\00\02\01\0A\03\02\02\04\03\01\02\05\03\02\02\07\03\02\01\02\00\01\01\01\02\03\03\03\02\03\03\02\02\06\03\01\01\06\00\01\01\05\02\01\01\01\03\01\02\01\03\01\01\03\02\01\03\01\01\02\03\02\02\01\01\0E\00\02\01\0A\03\03\02\01\03\02\02\06\03\02\02\07\03\04\01\02\02\02\03\03\02\03\03\02\02\06\03\01\01\04\00\01\01\06\02\01\01\01\03\01\02\01\03\02\01\04\02\01\03\03\02\01\01\10\00\02\01\0A\03\05\02\07\03\03\02\07\03\02\01\02\02\02\03\03\02\03\03\01\02\07\03\01\01\02\00\01\01\06\02\01\01\06\03\01\01\04\02\02\03\01\01\01\02\01\01\11\00\01\01\02\02\0C\03\02\02\08\03\02\02\07\03\01\01\02\02\02\03\03\02\0B\03\02\01\06\02\01\01\08\03\01\01\04\02\01\01\02\02\01\01\0E\00\03\01\06\02\07\03\02\02\02\03\03\02\07\03\01\02\07\03\01\01\04\02\02\03\02\02\09\03\01\01\01\02\01\03\04\02\01\01\0A\03\01\01\07\02\01\01\0C\00\01\01\09\03\04\02\03\03\01\02\06\03\03\02\02\03\01\02\02\03\02\02\05\03\01\01\01\03\03\02\04\03\01\02\08\03\01\01\02\03\03\02\01\01\01\02\0B\03\02\01\02\02\01\01\02\02\01\01\01\00\01\01\0B\00\01\01\0B\03\06\02\08\03\03\02\04\03\01\02\05\03\01\01\02\03\02\02\0C\03\01\01\02\03\03\02\01\01\11\03\01\01\02\02\01\01\01\02\01\01\0B\00\02\01\0F\03\02\02\09\03\01\02\04\03\01\02\04\03\01\01\04\03\02\02\09\03\01\01\01\02\02\03\03\02\01\01\08\03\04\01\06\03\01\01\02\02\01\01\0E\00\03\01\0E\03\03\02\07\03\01\02\03\03\01\02\05\03\01\01\05\03\01\02\07\03\01\01\02\02\02\03\02\02\01\01\0A\03\01\01\01\03\02\01\05\03\03\01\12\00\03\01\0D\03\07\02\02\03\02\02\02\03\01\02\04\03\01\01\02\02\03\03\02\02\06\03\01\01\02\02\02\03\02\02\01\01\0A\03\01\02\01\01\01\02\01\01\05\03\01\01\17\00\01\01\0C\02\08\03\01\02\04\03\01\02\04\03\01\01\03\02\09\03\01\01\04\02\01\03\02\02\01\01\14\03\01\01\14\00\02\01\0C\03\02\02\08\03\01\02\04\03\01\02\03\03\01\01\06\02\06\03\01\01\07\02\01\01\14\03\01\01\13\00\01\01\10\03\03\02\06\03\02\02\02\03\01\02\04\03\01\01\02\02\03\03\01\02\05\03\01\01\05\02\01\03\01\02\01\01\04\03\01\02\10\03\01\01\13\00\02\01\0B\03\04\02\01\03\08\02\04\03\01\02\03\03\01\01\03\02\08\03\01\01\05\02\01\03\01\02\01\01\04\03\01\02\11\03\01\01\14\00\05\01\06\02\04\03\01\02\07\03\02\02\03\03\01\02\03\03\01\01\03\02\07\03\01\01\09\02\01\01\03\03\02\02\11\03\01\01\18\00\01\01\0A\03\01\02\07\03\02\02\02\03\01\02\03\03\02\01\05\02\04\03\01\01\09\02\01\01\04\03\01\02\01\01\10\03\01\01\17\00\01\01\0C\03\08\02\04\03\01\02\03\03\01\01\03\02\06\03\01\01\0A\02\01\01\03\03\02\02\01\01\0C\03\01\02\03\03\01\01\15\00\01\01\09\03\03\02\04\03\02\02\02\03\02\02\03\03\01\02\03\03\01\01\06\02\03\03\01\01\06\02\01\01\03\02\01\01\04\03\02\02\05\01\07\03\02\01\02\03\01\01\16\00\06\01\03\02\06\03\01\02\06\03\01\02\02\03\01\02\04\03\01\01\04\02\03\03\01\01\06\02\01\01\01\03\01\01\02\02\01\01\04\03\05\02\01\01\01\00\02\01\02\03\01\02\03\03\01\01\02\03\01\01\1C\00\01\01\08\03\08\02\03\03\01\02\03\03\01\01\04\02\03\03\01\01\06\02\01\01\01\03\01\01\02\02\01\01\05\03\03\02\01\01\04\00\01\01\02\03\01\01\05\03\01\01\1B\00\01\01\06\03\08\02\02\03\01\02\03\03\01\02\04\03\01\01\06\02\01\01\07\02\01\01\02\02\01\01\07\03\02\02\01\01\05\00\01\01\01\03\01\02\01\01\03\03\01\01\1D\00\06\01\06\03\01\02\04\03\01\02\03\03\01\02\03\03\01\01\06\02\01\01\07\02\01\01\01\02\01\01\08\03\02\02\01\01\06\00\01\01\02\03\03\01\22\00\01\01\04\03\03\02\01\03\01\02\04\03\02\02\01\03\02\02\03\03\01\01\05\02\01\01\07\02\01\03\01\01\0A\03\01\02\01\01\07\00\02\01\26\00\03\01\03\02\03\03\04\02\04\03\01\02\04\03\01\01\04\02\01\01\09\02\01\01\0A\03\02\01\31\00\01\01\06\03\01\02\07\03\01\02\04\03\01\01\03\02\01\01\09\02\01\01\0A\03\01\01\01\02\01\01\30\00\01\01\05\03\01\02\01\03\01\02\03\03\02\02\02\03\01\02\04\03\01\01\03\02\01\01\02\02\01\01\06\02\01\01\09\03\01\01\02\02\01\01\30\00\02\01\03\02\03\03\03\02\05\03\01\02\04\03\01\01\02\02\01\01\01\02\01\01\01\03\01\01\05\02\01\01\09\03\01\01\03\02\01\01\23\00\06\01\08\00\01\01\06\03\02\02\03\03\01\02\02\03\01\02\04\03\04\01\03\03\01\01\04\02\01\01\09\03\01\01\02\02\01\03\01\02\01\01\20\00\02\01\06\02\02\01\06\00\01\01\05\03\02\02\01\03\03\02\04\03\01\02\05\03\01\01\05\03\01\01\03\02\01\01\0A\03\01\01\02\02\02\03\02\01\1C\00\02\01\0A\02\01\01\06\00\01\01\04\02\04\03\01\02\05\03\01\02\0C\03\01\01\02\02\01\01\0A\03\01\01\03\02\02\03\01\02\01\01\1A\00\01\01\04\02\05\03\04\02\01\01\03\00\06\01\05\03\05\02\02\03\01\02\0B\03\01\01\02\02\01\01\0A\03\01\01\05\02\01\03\01\02\01\01\18\00\01\01\04\02\03\03\08\02\01\01\01\00\01\01\06\03\05\02\03\03\01\02\04\03\01\02\0A\03\01\01\01\02\01\01\0B\03\01\01\05\02\02\03\01\01\17\00\01\01\04\02\02\03\0B\02\01\01\0A\03\01\02\03\03\02\02\02\03\02\02\0A\03\01\01\02\02\01\01\0B\03\01\01\03\02\01\03\01\01\03\03\01\01\16\00\01\01\03\02\01\03\02\02\02\03\08\02\01\01\0C\03\03\02\01\03\03\02\0B\03\01\01\01\02\02\01\0C\03\01\01\03\02\02\03\01\01\01\02\01\03\01\01\15\00\01\01\05\02\02\03\09\02\01\01\1F\03\02\01\0E\03\01\02\01\01\02\02\02\03\02\01\01\03\01\01\14\00\01\01\05\02\02\03\06\02\05\01\30\03\01\01\03\02\02\03\02\01\15\00\01\01\05\02\01\03\05\02\02\01\03\00\01\01\31\03\01\01\03\02\02\03\01\01\16\00\01\01\01\03\03\02\01\03\05\02\02\01\04\00\01\01\31\03\01\01\03\02\02\03\01\01\15\00\01\01\01\02\01\03\01\02\01\03\01\02\01\03\05\02\01\01\04\00\01\01\32\03\01\01\03\02\01\03\01\02\01\01\15\00\01\01\01\02\04\03\05\02\01\01\05\00\01\01\32\03\01\01\03\02\01\03\01\02\01\01\14\00\01\01\03\02\03\03\05\02\01\01\05\00\01\01\32\03\01\01\04\02\01\01\15\00\01\01\05\02\01\03\04\02\01\01\06\00\01\01\32\03\01\01\04\02\01\01\15\00\01\01\05\02\01\03\04\02\01\01\06\00\01\01\0D\03\01\02\23\03\01\01\05\02\01\01\04\00\01\01\10\00\01\01\0A\02\01\01\06\00\01\01\0D\03\01\02\23\03\01\01\06\02\01\01\02\00\01\01\01\02\01\01\0F\00\01\01\0A\02\01\01\06\00\01\01\01\02\0C\03\02\02\0F\03\01\02\0E\03\01\02\02\03\01\02\02\01\05\02\01\03\02\01\01\02\01\03\01\01\0F\00\01\01\0A\02\01\01\06\00\01\01\01\02\0C\03\02\02\0F\03\01\02\0E\03\01\02\01\03\02\02\01\01\01\00\01\01\05\02\01\03\01\02\01\03\01\01\11\00\01\01\0A\02\01\01\05\00\01\01\01\02\0C\03\04\02\0D\03\01\02\09\03\01\02\03\03\02\02\01\03\01\02\02\03\01\01\01\00\02\01\05\02\01\01\12\00\01\01\0A\02\01\01\05\00\01\01\01\02\0C\03\06\02\0B\03\02\02\08\03\01\02\02\03\05\02\03\03\01\01\02\00\05\01\13\00\01\01\0A\02\01\01\06\00\01\01\01\02\0B\03\04\01\06\02\06\03\03\02\08\03\01\02\01\03\05\02\05\03\01\01\1A\00\01\01\0A\02\01\01\05\00\01\01\01\02\0B\03\01\01\03\02\03\01\0D\02\07\03\03\02\01\01\03\02\06\03\01\01\19\00\01\01\0A\02\01\01\05\00\01\01\01\02\0A\03\01\01\07\02\04\01\09\02\07\03\03\01\05\02\06\03\01\01\19\00\01\01\09\02\01\01\05\00\01\01\01\02\08\03\01\02\02\01\08\02\01\01\02\00\09\01\07\03\01\01\02\00\03\01\04\02\05\03\01\01\18\00\01\01\0A\02\01\01\04\00\01\01\01\02\07\03\02\02\02\01\08\02\01\01\0A\00\01\01\06\03\01\02\01\01\05\00\02\01\03\02\05\03\01\01\18\00\01\01\09\02\01\01\04\00\01\01\01\02\06\03\02\02\01\01\01\00\01\01\08\02\01\01\0A\00\01\01\06\03\01\01\08\00\03\01\02\02\04\03\01\01\17\00\01\01\09\02\01\01\03\00\01\01\02\02\05\03\02\02\01\01\02\00\01\01\07\02\01\01\0C\00\01\01\05\03\01\01\0B\00\01\01\01\02\04\03\01\01\17\00\01\01\09\02\01\01\03\00\01\01\02\02\04\03\02\02\01\01\03\00\01\01\06\02\01\01\0D\00\01\01\05\03\01\01\0C\00\01\01\01\02\03\03\01\01\0E\00\02\01\07\00\01\01\09\02\01\01\03\00\01\01\01\02\04\03\02\02\01\01\03\00\01\01\06\02\01\01\0E\00\01\01\01\02\04\03\01\01\0C\00\01\01\03\02\01\01\0E\00\02\01\01\03\01\01\06\00\01\01\08\02\01\01\03\00\01\01\05\03\02\02\01\01\04\00\01\01\05\02\01\01\10\00\01\01\04\03\01\01\0C\00\01\01\03\02\01\01\0D\00\01\01\01\02\01\01\01\03\01\01\05\00\01\01\09\02\01\01\02\00\01\01\05\03\02\02\01\01\04\00\01\01\05\02\01\01\11\00\01\01\04\03\01\01\0B\00\01\01\03\02\01\01\0E\00\01\01\01\02\01\01\02\03\01\01\03\00\01\01\0A\02\01\01\01\00\01\01\05\03\02\02\01\01\05\00\01\01\04\02\01\01\12\00\01\01\04\03\01\01\0B\00\01\01\01\02\01\03\01\02\01\01\0E\00\01\01\01\02\01\01\03\03\03\01\0A\02\01\01\02\00\01\01\04\03\02\02\01\01\06\00\01\01\04\02\01\01\12\00\01\01\04\03\01\01\0A\00\01\01\04\02\01\01\0E\00\01\01\02\02\01\01\05\03\01\01\09\02\01\01\02\00\01\01\04\03\01\02\01\01\07\00\01\01\04\02\01\01\12\00\01\01\04\03\01\01\09\00\01\01\04\02\01\01\0F\00\01\01\03\02\05\01\09\02\01\01\03\00\01\01\04\03\01\01\09\00\01\01\03\02\01\01\12\00\01\01\04\03\01\01\09\00\01\01\04\02\01\01\0F\00\01\01\11\02\01\01\03\00\01\01\04\03\01\01\09\00\01\01\03\02\01\01\12\00\01\01\04\03\01\01\07\00\03\01\03\02\01\01\10\00\01\01\10\02\01\01\04\00\01\01\04\03\01\01\0A\00\01\01\03\02\01\01\11\00\01\01\01\02\03\03\01\01\06\00\01\01\06\02\01\01\11\00\01\01\0E\02\01\01\05\00\01\01\03\03\01\01\0B\00\01\01\03\02\01\01\12\00\01\01\03\03\01\01\05\00\01\01\05\02\01\03\01\01\13\00\01\01\0C\02\01\01\06\00\01\01\03\03\01\01\0B\00\01\01\03\02\01\01\12\00\01\01\03\03\01\01\05\00\01\01\05\02\01\01\15\00\02\01\08\02\02\01\07\00\01\01\03\03\01\01\0B\00\01\01\04\02\01\01\11\00\01\01\03\03\01\01\05\00\01\01\02\02\01\01\01\02\01\01\18\00\08\01\09\00\01\01\03\03\01\01\0C\00\01\01\03\02\01\01\11\00\01\01\03\03\01\01\05\00\01\01\03\02\01\01\2A\00\01\01\03\03\01\01\0C\00\01\01\03\02\01\01\11\00\01\01\03\03\01\01\05\00\04\01\2B\00\01\01\03\03\01\01\0C\00\01\01\04\02\01\01\10\00\01\01\03\03\01\01\33\00\01\01\04\03\01\01\0C\00\01\01\04\02\01\01\10\00\01\01\04\03\01\01\32\00\01\01\04\03\01\01\0C\00\01\01\05\02\01\01\0F\00\01\01\04\03\01\01\32\00\01\01\04\03\01\01\0D\00\01\01\04\02\01\01\0F\00\01\01\04\03\01\01\32\00\01\01\04\03\01\01\0E\00\01\01\04\02\01\01\0E\00\01\01\05\03\01\01\31\00\01\01\01\02\03\03\01\01\0E\00\01\01\04\02\01\01\0F\00\01\01\04\03\01\01\32\00\01\01\04\03\01\01\0D\00\01\01\05\02\01\01\0E\00\01\01\01\02\04\03\01\01\31\00\01\01\02\03\02\02\01\01\0D\00\01\01\05\02\01\01\0F\00\01\01\03\03\01\02\01\01\31\00\01\01\03\02\01\03\01\02\01\01\0D\00\06\01\0F\00\01\01\03\02\01\03\01\02\01\01\30\00\01\01\02\02\03\03\01\01\22\00\01\01\02\02\03\03\01\02\01\01\2F\00\01\01\02\02\03\03\01\01\23\00\01\01\01\02\03\03\01\02\01\01\30\00\06\01\23\00\07\01\13\00"

		;; original: 6144 bytes → compressed: 3400 bytes
		;; 497068 player_32x32x6p_192
		"\43\00\01\01\18\00\01\01\05\00\01\01\01\03\01\01\0A\00\02\02\0A\00\01\01\01\03\01\01\03\00\01\01\02\03\01\01\08\00\01\01\01\00\02\02\01\00\01\01\08\00\01\01\02\03\01\01\02\00\02\01\02\03\02\01\05\00\01\01\01\03\01\01\02\02\01\01\01\03\01\01\05\00\02\01\02\03\02\01\01\00\01\01\06\03\02\01\03\00\01\01\02\03\02\01\02\03\01\01\03\00\02\01\06\03\01\01\01\00\02\01\06\03\02\01\01\00\03\01\02\02\03\01\01\00\02\01\06\03\02\01\01\00\01\01\0A\03\03\01\04\02\03\01\0A\03\01\01\01\00\02\01\09\03\01\01\06\02\01\01\09\03\02\01\04\00\01\01\01\02\07\03\01\01\06\02\01\01\07\03\01\02\01\01\05\00\01\01\0A\03\01\01\04\02\01\01\0A\03\01\01\05\00\03\01\08\03\04\02\08\03\03\01\07\00\01\01\08\03\01\01\04\02\01\01\08\03\01\01\09\00\02\01\05\03\01\02\01\01\04\02\01\01\06\03\02\01\0C\00\02\01\03\03\01\02\01\01\04\02\01\01\01\02\03\03\02\01\10\00\02\01\02\03\06\02\02\03\02\01\13\00\01\01\02\03\06\02\02\03\01\01\14\00\01\01\01\02\02\03\01\01\02\02\01\01\02\03\01\02\01\01\14\00\01\01\01\02\02\03\01\01\02\02\01\01\02\03\01\02\01\01\15\00\01\01\01\02\01\01\04\02\01\01\01\02\01\01\16\00\01\01\01\02\01\01\04\02\01\01\01\02\01\01\16\00\01\01\02\03\01\01\02\02\01\01\02\03\01\01\16\00\01\01\02\03\01\01\02\02\01\01\02\03\01\01\16\00\01\01\02\03\01\01\02\02\01\01\02\03\01\01\16\00\01\01\02\03\01\02\02\01\01\02\02\03\01\01\16\00\01\01\02\03\01\02\02\01\01\02\02\03\01\01\16\00\01\01\02\03\01\01\02\00\01\01\02\03\01\01\16\00\04\01\02\00\04\01\16\00\01\01\02\02\01\01\02\00\01\01\02\02\01\01\16\00\01\01\02\02\01\01\02\00\01\01\02\02\01\01\16\00\03\01\04\00\03\01\3A\00\02\02\1C\00\01\01\01\00\02\02\01\00\01\01\19\00\01\01\01\03\01\01\02\02\01\01\01\03\01\01\18\00\01\01\02\03\02\01\02\03\01\01\18\00\03\01\02\02\03\01\19\00\01\01\04\02\01\01\19\00\01\01\06\02\01\01\0D\00\06\01\05\00\01\01\06\02\01\01\05\00\06\01\01\00\01\01\06\03\03\01\02\00\02\01\04\02\02\01\02\00\03\01\06\03\02\01\09\03\03\01\01\03\04\02\01\03\03\01\09\03\01\01\01\00\03\01\01\02\01\03\01\02\06\03\01\01\04\02\01\01\06\03\01\02\01\03\01\02\03\01\05\00\02\01\02\03\01\02\04\03\01\01\04\02\01\01\04\03\01\02\02\03\02\01\0A\00\02\01\05\03\01\01\04\02\01\01\05\03\02\01\0E\00\03\01\02\03\06\02\03\03\02\01\12\00\01\01\02\03\06\02\02\03\01\01\14\00\01\01\01\02\02\03\01\01\02\02\01\01\02\03\01\02\01\01\14\00\01\01\01\02\02\03\01\01\02\02\01\01\02\03\01\02\01\01\15\00\01\01\01\02\01\01\04\02\01\01\01\02\01\01\16\00\01\01\01\02\01\01\04\02\01\01\01\02\01\01\16\00\01\01\02\03\01\01\02\02\01\01\02\03\01\01\16\00\01\01\02\03\01\01\02\02\01\01\02\03\01\01\16\00\01\01\01\03\01\02\01\01\02\02\01\01\01\02\01\03\01\01\15\00\01\01\02\03\06\01\02\03\01\01\14\00\01\01\02\03\01\01\01\00\02\01\01\00\01\01\02\03\01\01\14\00\04\01\04\00\04\01\14\00\01\01\02\02\01\01\04\00\01\01\02\02\01\01\14\00\01\01\02\02\01\01\04\00\01\01\02\02\01\01\14\00\03\01\06\00\03\01\AC\00\01\01\12\00\02\01\06\00\01\01\03\00\01\01\01\03\01\01\0F\00\02\01\01\03\01\01\05\00\01\01\01\03\01\01\02\00\01\01\02\03\01\01\0A\00\02\01\01\00\01\01\02\03\01\02\01\01\04\00\01\01\02\03\01\01\02\00\02\01\02\03\02\01\07\00\01\01\01\02\01\03\01\01\02\03\01\02\01\01\03\00\02\01\02\03\02\01\01\00\01\01\03\03\01\02\02\03\02\01\05\00\01\01\01\02\02\03\01\01\02\02\01\01\01\00\02\01\02\03\01\02\03\03\01\01\01\00\02\01\02\03\02\02\02\03\02\01\03\00\01\01\01\02\04\03\03\01\02\03\02\02\02\03\02\01\01\00\01\01\06\03\02\02\02\03\03\01\01\02\02\03\02\02\02\03\01\01\01\03\02\02\06\03\01\01\01\00\02\01\06\03\02\02\01\03\01\01\02\02\07\03\01\01\06\03\02\01\04\00\01\01\01\02\01\03\01\02\04\03\01\02\01\01\02\02\07\03\01\01\02\03\01\02\01\03\01\02\01\01\05\00\01\01\05\03\01\02\03\03\01\01\01\02\07\03\01\01\01\03\01\02\05\03\01\01\05\00\03\01\04\03\01\02\02\01\01\02\03\03\01\02\03\01\01\02\04\03\03\01\07\00\01\01\03\03\01\02\02\03\01\01\02\02\04\03\01\01\01\02\01\01\02\03\01\02\03\03\01\01\09\00\02\01\03\03\01\02\01\01\03\02\03\03\01\01\02\02\01\01\03\03\02\01\0C\00\02\01\01\02\01\01\04\02\03\03\01\01\01\03\01\02\01\01\01\02\02\01\10\00\02\01\02\03\01\02\07\03\02\01\13\00\01\01\0A\03\01\01\14\00\01\01\01\02\08\03\01\02\01\01\14\00\01\01\01\02\08\03\01\02\01\01\15\00\01\01\01\02\06\03\01\02\01\01\16\00\01\01\01\02\01\03\01\02\02\03\01\02\01\03\01\02\01\01\16\00\01\01\02\03\01\01\02\02\01\01\02\03\01\01\16\00\01\01\02\03\01\01\02\02\01\01\02\03\01\01\16\00\01\01\02\03\04\01\02\03\01\01\16\00\01\01\02\03\01\01\02\00\01\01\02\03\01\01\16\00\01\01\02\03\01\01\02\00\01\01\02\03\01\01\16\00\01\01\01\03\01\02\01\01\02\00\01\01\01\02\01\03\01\01\15\00\01\01\03\03\01\01\02\00\01\01\03\03\01\01\14\00\01\01\02\02\01\01\04\00\01\01\02\02\01\01\14\00\01\01\02\02\01\01\04\00\01\01\02\02\01\01\14\00\03\01\06\00\03\01\3F\00\02\01\1C\00\02\01\01\03\01\01\18\00\02\01\01\00\01\01\02\03\01\02\01\01\17\00\01\01\01\02\01\03\01\01\02\03\01\02\01\01\18\00\01\01\01\02\02\03\01\01\02\02\01\01\18\00\01\01\01\02\04\03\01\01\0D\00\02\01\09\00\01\01\01\02\02\03\02\02\02\03\01\01\06\00\02\01\03\00\01\01\02\03\03\01\05\00\01\01\02\02\07\03\01\01\02\00\03\01\02\03\01\01\01\00\01\01\02\03\02\02\02\03\04\01\01\00\01\01\02\02\07\03\03\01\02\03\02\02\02\03\02\01\05\03\03\02\02\03\02\01\01\02\07\03\01\01\01\03\03\02\05\03\01\01\01\00\03\01\01\02\01\03\01\02\03\03\01\02\02\01\01\02\03\03\01\02\03\01\01\02\03\03\01\02\01\03\01\02\03\01\05\00\02\01\02\03\03\02\01\01\02\02\04\03\01\01\01\02\01\01\03\02\02\03\02\01\0A\00\02\01\02\03\01\02\01\01\03\02\03\03\01\01\02\02\01\01\02\03\02\01\0E\00\03\01\04\02\03\03\01\01\01\03\01\02\03\01\12\00\01\01\02\03\01\02\07\03\01\01\14\00\01\01\0A\03\01\01\14\00\01\01\01\02\08\03\01\02\01\01\14\00\01\01\01\02\08\03\01\02\01\01\15\00\01\01\01\02\06\03\01\02\01\01\16\00\01\01\01\02\01\03\01\02\02\03\01\02\01\03\01\02\01\01\16\00\01\01\02\03\01\01\02\02\01\01\02\03\01\01\16\00\01\01\02\03\02\01\01\02\01\01\02\03\01\01\16\00\01\01\02\03\01\01\01\00\02\01\02\03\01\01\16\00\01\01\02\03\01\01\02\00\01\01\02\03\01\01\15\00\01\01\03\03\01\01\02\00\01\01\03\03\01\01\14\00\01\01\02\02\01\01\04\00\01\01\02\02\01\01\14\00\01\01\02\02\01\01\04\00\01\01\02\02\01\01\14\00\03\01\06\00\03\01\6C\00\01\01\1E\00\01\01\01\03\01\01\1D\00\01\01\02\03\01\01\1C\00\02\01\02\03\02\01\06\00\04\01\0F\00\01\01\03\03\01\02\02\03\02\01\03\00\01\01\04\03\01\01\0C\00\02\01\01\00\02\01\02\03\02\02\02\03\02\01\02\00\01\01\04\03\01\01\09\00\02\01\01\03\02\01\06\03\02\02\02\03\03\01\05\03\01\01\03\00\05\01\02\03\01\02\01\01\01\00\02\01\06\03\02\02\02\03\01\01\05\03\01\01\02\00\01\01\02\02\01\03\01\01\02\03\01\02\01\01\04\00\01\01\01\02\01\03\01\02\04\03\02\02\01\03\01\01\05\03\02\01\03\02\02\03\01\01\02\02\01\01\03\00\01\01\05\03\01\02\03\03\02\02\01\03\01\01\05\03\01\01\01\03\02\02\04\03\01\01\05\00\03\01\04\03\01\02\02\03\02\02\01\03\01\01\03\03\01\01\01\02\01\03\01\02\02\03\02\02\02\03\01\01\05\00\01\01\03\03\01\02\05\03\02\02\01\03\01\01\02\03\01\01\03\02\07\03\01\01\05\00\02\01\03\03\01\02\01\03\01\02\02\03\01\02\01\03\01\01\02\03\01\01\03\02\07\03\01\01\07\00\02\01\01\02\05\03\01\02\01\03\01\01\01\03\01\01\03\02\05\03\03\01\0A\00\02\01\01\03\02\02\02\03\01\02\01\03\01\01\04\02\03\03\01\02\01\01\09\00\03\01\03\00\01\01\04\03\01\02\01\03\01\01\05\02\03\03\01\01\08\00\01\01\03\02\02\01\01\00\02\01\05\03\01\01\05\02\03\03\02\01\07\00\01\01\05\02\01\01\01\02\05\03\01\02\01\01\01\02\01\03\02\02\04\03\01\01\01\02\01\01\05\00\01\01\06\02\11\03\01\01\02\02\01\01\04\00\01\01\03\02\04\01\11\03\01\01\01\02\01\01\03\00\01\01\03\02\01\01\03\00\01\01\11\03\01\01\01\02\01\01\03\00\01\01\03\02\01\01\03\00\01\01\01\02\03\03\01\02\0B\03\01\01\01\02\01\01\04\00\01\01\04\02\01\01\03\00\01\01\03\03\02\02\07\03\01\02\01\03\03\01\06\00\01\01\04\02\01\01\02\00\01\01\03\03\03\01\04\02\02\03\01\02\02\01\08\00\01\01\04\02\01\01\01\00\01\01\01\02\02\03\01\02\01\01\02\02\04\01\02\03\01\01\01\02\01\01\06\00\01\01\02\00\01\01\03\02\01\01\01\00\01\01\02\03\01\02\01\01\02\02\01\01\03\00\01\01\02\03\01\01\01\02\01\01\05\00\01\01\01\02\01\01\01\00\01\01\02\02\01\01\01\00\01\01\02\03\01\02\02\01\01\02\01\01\05\00\01\01\01\03\01\01\01\02\01\01\05\00\01\01\02\02\01\01\03\02\01\01\01\00\01\01\01\03\01\02\01\01\01\00\01\01\01\02\01\01\05\00\01\01\01\03\01\01\01\02\01\01\05\00\01\01\05\02\01\01\02\00\01\01\01\03\01\01\02\00\01\01\01\02\01\01\05\00\01\01\01\03\01\01\02\02\01\01\05\00\01\01\03\02\01\01\03\00\01\01\01\03\01\01\02\00\01\01\02\02\01\01\04\00\01\01\02\03\01\01\01\02\01\01\06\00\03\01\04\00\01\01\02\02\01\01\02\00\01\01\01\02\01\01\04\00\01\01\02\02\03\01\0E\00\03\01\02\00\03\01\05\00\03\01\64\00\02\01\1C\00\02\01\01\03\01\01\17\00\05\01\02\03\01\02\01\01\16\00\01\01\02\02\01\03\01\01\02\03\01\02\01\01\16\00\01\01\03\02\02\03\01\01\02\02\01\01\16\00\01\01\01\03\02\02\04\03\01\01\16\00\01\01\01\02\01\03\01\02\02\03\02\02\02\03\01\01\03\00\02\01\10\00\01\01\03\02\07\03\01\01\01\00\01\01\02\03\03\01\08\00\02\01\03\00\01\01\03\02\07\03\02\01\02\03\02\02\02\03\04\01\03\00\01\01\02\03\03\01\03\02\05\03\03\01\01\00\01\01\05\03\03\02\02\03\03\01\05\03\01\01\03\02\03\03\01\02\01\01\05\00\03\01\01\02\01\03\01\02\03\03\03\02\01\03\02\01\03\03\01\01\04\02\03\03\01\01\08\00\02\01\02\03\03\02\02\03\02\02\01\03\01\01\01\03\01\01\05\02\03\03\01\01\09\00\03\01\02\03\01\02\01\03\01\02\02\03\01\02\01\03\02\01\01\02\01\03\02\02\04\03\02\01\0B\00\03\01\01\03\02\02\02\03\01\02\01\03\01\01\01\02\07\03\01\01\01\02\01\01\06\00\04\01\02\02\01\01\01\02\05\03\01\02\01\01\09\03\02\01\05\00\01\01\06\02\07\03\01\01\0A\03\02\01\04\00\01\01\04\02\04\01\11\03\01\01\04\00\01\01\04\02\01\01\03\00\01\01\01\02\03\03\01\02\0B\03\01\01\05\00\01\01\03\02\01\01\05\00\01\01\03\03\02\02\07\03\01\02\01\03\01\01\06\00\01\01\04\02\01\01\04\00\01\01\03\03\03\01\04\02\02\03\01\02\02\01\07\00\01\01\04\02\01\01\01\00\02\01\03\03\01\02\01\01\02\02\04\01\02\03\01\01\01\02\02\01\07\00\01\01\04\02\01\01\04\03\01\02\01\01\02\02\01\01\03\00\01\01\02\03\02\01\02\02\01\01\06\00\01\01\04\02\01\01\01\03\05\01\01\02\01\01\05\00\01\01\01\03\05\01\04\00\01\01\02\00\01\01\03\02\01\01\01\03\01\01\02\00\01\01\02\02\01\01\05\00\01\01\02\03\01\01\06\00\01\01\01\02\01\01\01\00\01\01\02\02\02\01\02\02\01\01\02\00\01\01\01\02\01\01\06\00\01\01\02\03\01\01\05\00\01\01\02\02\01\01\03\02\01\01\01\00\03\01\02\00\02\01\07\00\01\01\02\02\01\01\05\00\01\01\05\02\01\01\11\00\03\01\06\00\01\01\03\02\01\01\1C\00\03\01\1B\00"

		;; original: 256 bytes → compressed: 186 bytes
		;; 500468 cloud_16x16
		"\11\01\01\02\02\01\03\03\01\01\01\02\03\01\03\02\03\01\06\03\01\01\01\03\02\02\01\01\02\02\03\01\07\03\01\01\01\03\02\02\01\01\01\02\02\01\0B\03\01\02\01\01\01\02\02\01\0A\03\02\02\01\01\01\02\02\01\09\03\03\02\01\01\01\02\03\01\04\03\02\02\02\03\01\02\02\01\01\02\03\01\01\02\01\01\02\03\02\02\01\01\05\03\02\02\03\01\01\03\04\01\07\03\01\02\02\01\0D\03\01\02\02\01\02\03\01\02\03\01\03\03\01\01\01\03\02\02\04\01\01\02\01\01\07\03\02\01\01\02\03\01\01\02\01\01\04\03\01\02\04\03\01\02\01\01\01\02\02\01\02\02\01\01\01\03\02\02\01\01\04\02\01\01\02\02\11\01"

		;; original: 256 bytes → compressed: 174 bytes
		;; 500654 rgb_orb_16x16
		"\16\00\04\01\0A\00\02\01\04\02\02\01\07\00\01\01\08\02\01\01\05\00\01\01\02\02\02\03\01\02\01\01\04\02\01\01\04\00\01\01\01\02\04\03\01\02\01\01\03\02\01\01\03\00\01\01\02\02\04\03\01\02\01\01\04\02\01\01\02\00\01\01\03\02\02\03\01\02\03\01\01\02\01\01\01\02\01\01\02\00\01\01\02\02\01\01\02\02\05\01\02\02\01\01\02\00\01\01\03\02\07\01\02\02\01\01\03\00\01\01\04\02\01\01\01\03\01\01\01\03\01\01\01\02\01\01\04\00\01\01\05\02\04\01\01\02\01\01\05\00\01\01\03\02\01\01\04\02\01\01\07\00\02\01\04\02\02\01\0A\00\04\01\16\00"

		;; original: 1024 bytes → compressed: 914 bytes
		;; 500828 pack_01_8x8x16p
		"\09\00\02\01\01\00\03\01\01\00\01\01\02\02\01\01\03\02\02\01\01\02\01\03\01\01\03\02\02\01\06\02\01\01\01\00\01\01\04\02\01\01\03\00\01\01\02\02\01\01\05\00\02\01\04\00\02\01\01\00\03\01\01\00\01\01\02\02\01\01\03\02\02\01\01\03\01\02\01\01\02\03\01\02\02\01\06\02\01\01\01\00\03\01\02\02\01\01\02\00\01\01\01\03\01\01\02\03\01\01\03\00\03\01\01\03\01\01\05\00\02\01\03\00\05\03\01\01\02\00\01\03\03\02\02\03\02\00\06\03\02\00\01\03\02\02\01\03\01\02\01\03\02\00\06\03\02\00\02\03\02\02\02\03\02\00\04\03\01\02\01\03\02\00\01\01\05\03\0A\00\02\03\02\00\02\03\02\00\01\03\04\00\01\03\12\00\01\03\04\00\01\03\02\00\02\03\02\00\02\03\15\00\01\03\01\00\01\03\02\00\02\03\02\00\02\03\03\00\05\03\02\00\05\03\05\00\01\03\01\00\01\03\03\00\01\03\04\00\01\03\12\00\05\03\01\02\01\01\01\00\02\02\01\03\03\02\01\01\01\00\02\01\01\03\01\02\03\01\03\00\01\03\01\02\01\01\03\00\03\03\01\02\01\01\03\00\04\02\01\01\03\00\05\01\0B\00\01\03\01\02\01\01\01\00\01\03\01\02\01\01\01\00\01\03\01\02\01\01\01\03\02\02\01\01\01\00\04\03\01\02\01\01\02\00\04\03\01\02\01\01\02\00\01\03\01\02\01\01\01\02\01\03\01\02\01\01\01\00\02\02\02\01\02\02\01\01\01\00\03\01\01\00\03\01\02\00\01\03\01\02\02\03\03\00\01\03\04\02\01\03\01\00\01\03\02\02\02\01\02\02\02\03\01\02\04\01\04\02\04\01\01\02\02\03\02\02\02\01\02\02\01\03\01\00\01\03\04\02\01\03\03\00\02\03\01\02\01\03\02\00\01\03\01\02\01\03\01\02\01\03\01\02\01\03\02\02\01\03\01\02\01\03\01\02\01\03\01\02\02\03\01\02\01\03\01\02\01\03\01\02\01\03\02\02\01\03\01\02\01\03\01\02\01\03\01\02\02\03\01\02\01\03\01\02\01\03\01\02\01\03\02\02\01\03\01\02\01\03\01\02\01\03\01\02\02\03\01\02\01\03\01\02\01\03\01\02\01\03\02\02\01\03\01\02\01\03\01\02\01\03\01\02\01\03\03\00\02\03\05\00\01\03\02\01\01\03\03\00\01\03\04\01\01\03\01\00\01\03\06\01\04\03\02\01\03\03\02\00\01\03\02\01\01\03\04\00\01\03\02\01\01\03\04\00\04\03\0C\00\04\01\03\00\01\01\04\03\01\01\02\00\01\01\04\03\01\01\01\00\01\01\01\03\04\01\01\03\03\01\04\03\0A\01\01\00\06\01\13\00\04\01\02\00\02\01\04\03\03\01\06\03\03\01\04\03\02\01\01\00\06\01\0A\00\06\01\02\00\01\01\04\03\01\01\01\00\01\01\02\03\02\01\02\03\02\01\01\03\01\01\02\03\01\01\01\03\02\01\01\03\01\01\02\03\01\01\01\03\02\01\01\02\01\01\02\02\01\01\01\02\02\01\06\02\01\01\01\00\06\01\04\00\02\01\05\00\01\01\02\02\01\01\03\00\01\01\01\03\02\02\01\03\01\01\01\00\01\03\02\02\02\03\02\02\01\03\01\00\01\03\04\02\01\03\03\00\04\03\05\00\02\01\05\00\04\01\0C\00\04\03\03\00\01\03\04\00\01\03\02\00\01\03\01\00\02\03\01\00\01\03\04\00\02\03\04\00\06\03\03\00\01\03\02\00\01\03\0B\00\01\03\01\00\02\03\01\00\01\03\02\00\02\03\02\00\02\03\02\00\01\03\01\00\02\03\01\00\01\03\02\00\01\03\01\00\02\03\01\00\01\03\02\00\01\03\01\00\02\03\01\00\01\03\02\00\01\03\04\00\01\03\03\00\04\03\0A\00"

		;; data for decompress function
		;; original: 18432 bytes → compressed: 5524 bytes 
		;; 482482 chinese_title_288x64
		"\B2\5C\07\00" ;; 501742 (482482 src_addr)
		"\00\40\06\00" ;; 501746 (409600 des_addr)
		"\E6\27\00\00" ;; 501750 (10214  compress)
		;; 488006 charset_8x16x48v
		;; original: 6144 bytes → compressed: 4814 bytes
		"\46\72\07\00" ;; 501754 (488006 src_addr)
		"\00\E0\06\00" ;; 501758 (450560 des_addr)
		"\CE\12\00\00" ;; 501762 (4814   compress)
		;; 492820 pointer_16x16x2f
		;; original: 512 bytes → compressed: 212 bytes
		"\14\85\07\00" ;; 501766 (492820 src_addr)
		"\00\F8\06\00" ;; 501770 (456704 des_addr)
		"\D4\00\00\00" ;; 501774 (212    compress)
		;; 493032 title_lumy_96x104
		;; original: 9984 bytes → compressed: 4036 bytes
		"\E8\85\07\00" ;; 501778 (493032 src_addr)
		"\00\FA\06\00" ;; 501782 (457216 des_addr)
		"\C4\0F\00\00" ;; 501786 (4036   compress)
		;; 497068 player_32x32x6p_192
		;; original: 6144 bytes → compressed: 3400 bytes
		"\AC\95\07\00" ;; 501790 (497068 src_addr)
		"\00\21\07\00" ;; 501794 (467200 des_addr)
		"\48\0D\00\00" ;; 501798 (3400   compress)
		;; 500468 cloud_16x16
		;; original: 256 bytes → compressed: 186 bytes
		"\F4\A2\07\00" ;; 501802 (500468 src_addr)
		"\00\39\07\00" ;; 501806 (473344 des_addr)
		"\BA\00\00\00" ;; 501810 (186    compress)
		;; 500654 rgb_orb_16x16
		;; original: 256 bytes → compressed: 174 bytes
		"\AE\A3\07\00" ;; 501814 (500654 src_addr)
		"\00\3A\07\00" ;; 501818 (473600 des_addr)
		"\AE\00\00\00" ;; 501822 (174    compress)
		;; 500828 pack_01_8x8x16p
		;; original: 1024 bytes → compressed: 914 bytes
		"\5C\A4\07\00" ;; 501826 (500828 src_addr)
		"\00\3B\07\00" ;; 501830 (473856 des_addr)
		"\92\03\00\00" ;; 501834 (914    compress)

		;; 501838 word_data
		;; 0x00=A 0x01=B 0x02=C 0x03=D 0x04=E 0x05=F 0x06=G 0x07=H
		;; 0x08=I 0x09=J 0x0A=K 0x0B=L 0x0C=M 0x0D=N 0x0E=O 0x0F=P
		;; 0x10=Q 0x11=R 0x12=S 0x13=T 0x14=U 0x15=V 0x16=W 0x17=X
		;; 0x18=Y 0x19=Z 0x1A=0 0x1B=1 0x1C=2 0x1D=3 0x1E=4 0x1F=5 
		;; 0x20=6 0x21=7 0x22=8 0x23=9 0x24=. 0x25=! 0x26=? 0x27=,
		;; 0x28=' 0x29=" 0x2A=+ 0x2B=- 0x2C=x 0x2D=÷ 0x2E=/ 0x2F=
				 
		;; start (5 bytes)
		"\12\13\00\11\13" ;; 501838 word_data
		;; about (5 bytes)
		"\00\01\0E\14\13" ;; 501843 word_data
		;; this game was made by (22 bytes)
		"\13\07\08\12\FF\06\00\0C\04\FF\16\00\12\FF\0C\00\03\04\FF\01\18\FF";; 501848 word_data
		;; kenny fully (11 bytes)
		"\0A\04\0D\0D\18\FF\05\14\0B\0B\18" ;; 501870 word_data
		;; KEYS: WSAD JK (13 bytes)
		"\0A\04\18\12\2F\FF\16\12\00\03\FF\09\0A" ;;501881 
		;; for js13k2026.Please enjoy the mini (35 bytes)
		"\05\0E\11\FF\09\12\1B\1D\0A\1C\1A\1C\20\24\0F\0B\04\00\12\04\FF\04\0D\09\0E\18\FF\13\07\04\FF\0C\08\0D\08" ;; 501881 word_data
		;; adventure. (10 bytes)
		"\00\03\15\04\0D\13\14\11\04\24" ;; 501916 word_data
		;; press K to go back (18 bytes)
		"\0F\11\04\12\12\FF\0A\FF\13\0E\FF\06\0E\FF\01\00\02\0A" ;; 501926 word_data
		;; task: find the 3 rgb orbs (25 bytes)
		"\13\00\12\0A\2F\FF\05\08\0D\03\FF\13\07\04\FF\1D\FF\11\06\01\FF\0E\11\01\12" ;; 501944 word_data
		;; thanks for playing (18 bytes)
		"\13\07\00\0D\0A\12\FF\05\0E\11\FF\0F\0B\00\18\08\0D\06" ;; 501982 word_data
		;; lumyora (7 bytes)
		"\0B\14\0C\18\0E\11\00";; 502000
		

		;; 
		;; TODO: new word schema is
		;; 0x00 number of letters (0 - 255) (\xx)
		;; 0x01 clr_rbga_00 (\xx\xx\xx\FF)
		;; 0x02 clr_rbga_01 (\xx\xx\xx\FF)
		;; 0x03 dx          (\xx\xx)
		;; 0x04 xy          (\xx\xx)
		;; 0x05 scale       (0 - 255) (\xx)

	)
)
