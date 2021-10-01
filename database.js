const _randomValues = {};
const games = {
    get: function (game) {
        const key = (game != null && game.collections != null) ? `database.games.${game.collections.get(0).shortName}.${game.title}` : null;

        return {
            get bookmark() {
                return key ? api.memory.get(`${key}.bookmark`) : false;
            },
            set bookmark(value) {
                if (key) {
                    api.memory.set(`${key}.bookmark`, value);
                    game.onFavoriteChanged();
                }
            },

            get played() {
                return game && game.lastPlayed && game.lastPlayed.getTime() === game.lastPlayed.getTime();
            },

            get random() {
                if (key != null) {
                    if (_randomValues[key] == null) {
                        _randomValues[key] = Math.random();
                    }

                    return _randomValues[key];
                }

                return 0;
            }
        }
    }
  };