--
-- Module context
--
-- @author Zhao Xinyu(xinyu16@staff.weibo.com)
-- @version 20160111
--
module(..., package.seeall)
local name = ...

function init(core)
    core.debug:n('Loading context...')
    local c = core.service_conf.context
    if not c then
        core.debug:w('NO context configured')
        return nil
    end
    local t = require(c)
    local cxt = t:new(core)
    cxt:run()
    return cxt
end

--
-- should be called by sub-class
--
function init_whitelist_data(self)
    local whitelist = require('conf.whitelist')
    
    self.is_testing_whitelist_user = false
    self.is_category_whilist_user = false

    local whitelist_data = whitelist.check(self.core.uid)
    if whitelist_data then
        local category = string.match(whitelist_data, '^(%l+)#[0-9]+')
        if category then
            self.is_testing_whitelist_user = true
            self.is_category_whitelist_user = true
            self.whitelist_category = category
            self.core.debug:n(self.core.uid .. ' is a testing whitelist user of ' .. category .. ' modules')
        else
            category = string.match(whitelist_data, '^(%l+)$')
            if category then
                self.is_category_whitelist_user = true
                self.whitelist_category = category
                self.core.debug:n(self.core.uid .. ' is a category whitelist user, the first position goes to ' .. category .. ' module')
            else
                ngx.log(ngx.ERR, 'Malformed value for whitelist uid ' .. self.core.uid .. ' : ' .. whitelist_data)
            end
        end
    end
end

function init_user_data(self)
    local utils = require('lib.utils')
    local _tstart = utils.microtime(true)
    local user_t = require('lib.user')
    self.user = user_t:new(self.core.uid)
    self.core.trace:append(string.format('init:user:ms:%.3f', (utils.microtime(true) - _tstart) * 1000))
end
