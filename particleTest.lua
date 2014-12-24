local CBE = require "CBEffects.Library"

		-- rain particle
		local heavy_rain
		heavy_rain = CBE.VentGroup {
			{
				preset = "rain",
				title = "plink",
				positionType = "atPoint",
				build = function ()
					return display.newImageRect("grow-1.png", 10, 10)
				end,
				alpha = 0.3,
				startAlpha = 0.3,
				endAlpha = 0.3,
				lifeStart = 0,
				fadeInTime = 0,
				lifeSpan = 100,
				physics = {
					sizeX = 1.5,
					velocity = 0			
				}	 
			},
			{
				preset = "rain",
				title = "rain",
				perEmit = 7,
				positionType = "inRect",
				rectLeft = 50,
				rectTop = -150,
				rectWidth = 1024,
				rectHeight = 150,
				build = function()
					return display.newImageRect("glow-1.png", 10, 80)
				end,
				onDeath = function(particle, vent)
					heavy_rain:translate("plink", particle.x, particle.y)
					heavy_rain:emit("plink")
				end,
				lifeStart = 1000,
				lifeSpan = 100,
				physics = {
					autoAngle = false,
					angles = { 260 },
					velocity = 20
				}
			}
		}
		heavy_rain:start("rain")


