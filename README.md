## Requirement
### monolith libraries
```bash
# led matrix
luarocks install https://github.com/hnd2/MONOLITH/releases/download/v0.0.1/monolith-dev-1.rockspec --tree=lua_modules --lua-dir=/usr/local/opt/lua@5.1

# music
luarocks install https://github.com/ulalume/monolith-music/releases/download/v0.1/music-dev-1.rockspec --tree=lua_modules --lua-dir=/usr/local/opt/lua@5.1

# graphics
luarocks install https://github.com/ulalume/monolith-graphics/releases/download/v0.1/graphics-dev-1.rockspec --tree=lua_modules --lua-dir=/usr/local/opt/lua@5.1

# util
luarocks install https://github.com/ulalume/monolith-util/releases/download/v0.1/util-dev-1.rockspec --tree=lua_modules --lua-dir=/usr/local/opt/lua@5.1
```

### 3rd party
```bash
# json
luarocks install rxi-json-lua  --tree=lua_modules --lua-dir=/usr/local/opt/lua@5.1
```
