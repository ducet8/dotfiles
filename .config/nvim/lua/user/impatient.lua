-- 2022.08.18 - ducet8@outlook.com

local status_ok, impatient = pcall(require, "impatient")
if not status_ok then
  return
end

impatient.enable_profile()
