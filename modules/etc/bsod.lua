local function bsod(err, monitor)
  local color = {}

  if monitor.isColor() then
    color.bg = colors.blue
  else
    color.bg = colors.gray
  end
  color.fg = colors.white

  monitor.setBackgroundColor(color.bg)
  monitor.clear()

  local function splitPrint(str)
    local tmp = {str}
    local posx, posy = monitor.getCursorPos()
    local mx, my = monitor.getSize()

    if #tmp[1] > mx - posx then
      local ab2 = posx

      for i = 1, #tmp[1] / 100 + 1 do
        local ab = i == 1 and posx or 0
        local ab3 = i ~= 1 and ab2 or 0
        tmp[i + 1] = tmp[1]:sub(i * (mx - ab) - (mx - ab - 1) - ab3, i * (mx - ab) - ab3)

        -- EXAMPLE: start at pos 2, max 10
        -- line 1 start:
        -- i * (mx - ab) - (mx - ab - 1) + ab3
        -- 1 * (10 - 2 = 8) - (10 - 2 - 1 = 7) + 0
        -- 1 * 8 - 7 + 0
        -- 1
        -- line 1 end:
        -- i * (mx - ab) - ab3
        -- 1 * (10 - 2) - 0
        -- 8
        -- works both cases
        --------------------------------------
        -- line 2 start:
        -- 2 * (mx - ab) - (mx - ab - 1) - ab3
        -- 2 * (10 - 0) - (10 - 0 - 1) - 2
        -- 2 * (10) - (9) - 2
        -- 20 - 9 - 2
        -- 9
        -- line 2 end:
        -- i * (mx - ab) - ab3
        -- 2 * (10 - 0) - 2
        -- 20 - 2
        -- 18
        --------------------------------------
        -- Line 3 start:
        -- 3 * (mx - ab) - (mx - ab - 1) - ab3
        -- 3 * (10 - 0) - (10 - 0 - 1) - 2
        -- 30 - 9 - 2
        -- 19
        -- line 3 end:
        -- 3 * (mx - ab) - ab3
        -- 3 * (10 - 0) - 2
        -- 30 - 2
        -- 28
        --------------------------------------
        -- line 4 start:
        -- 4 * (mx - ab) - (mx - ab - 1) - ab3
        -- 4 * (10 - 0) - (10 - 0 - 1) - 2
        -- 40 - 10 - 2
        -- 29
        -- Line 4 end:
        -- 4 * (mx - ab) - ab3
        -- 4 * (10 - 0) - 2
        -- 40 - 2
        -- 38

        -- logic works in all cases
      end
      table.remove(tmp, 1)
    end

    return tmp
  end

  if err == "Terminated" then
    monitor.setCursorPos(1, 1)
    monitor.write("Simplify Shop has been terminated.")
    return
  end

  monitor.setCursorPos(1, 1)
  monitor.write("Simplify Shop encountered an error it could not recover from.")

  monitor.setCursorPos(1, 3)
  monitor.write(err)

  monitor.setCursorPos(1, 5)
  monitor.write("Please let Fatboychummy#4287 on Discord know.")

end

return bsod
