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
            }
        }
    }
  };