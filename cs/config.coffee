module.exports = do ->
    bt = require 'bootstrapper'

    bt.ENV =
        LOG:
            level:
                INFO: true
                WARN: true
                DEBUG: true
                ERROR: true
                NOTICE: true
            ns: {}

        DEFAULT_PROTOCOLS: ['IDom', 'IHelper']

    bt
