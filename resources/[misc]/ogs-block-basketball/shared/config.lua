Config = {
    snatch_ball = 50, -- % that you succeed snatching the ball
    allow_dunking = true, -- should people be able to dunk?
    dunk_percent = 20, -- % that you succeed dunking
    easy_mode = true, -- easier to hit the ball, this should be set to true otherwise it is *really* hard to hit the ball

    Courts = {
        { -- Chamberlains
            blip = vector3(-212.88, -1507.64, 31.58),
            start = vector3(-212.88, -1507.64, 31.58),
            ball = vector3(-205.67, -1513.64, 30.64),

            home = {
                vector3(-197.95, -1504.71, 33.97),
                vector3(-197.95, -1504.71, 33.67),
            },

            guest = {
                vector3(-213.09, -1522.69, 33.97),
                vector3(-213.09, -1522.69, 33.67),
            },

            dunking = {
                home = vector4(-198.28, -1505.11, 33.77, 322.52),
                guest = vector4(-212.75, -1522.26, 33.66, 140.95),
            },

            queue = {
                minimum = 1, -- minimum users per team for a match to start
                timer = 15, -- how long (in seconds) until the match starts, after "minimum" users are in queue per team
                game = 300, -- how long (in seconds) a game lasts
            },

            board = {
                enabled = true, -- update the score & time on the board? (this impacts performance, ~0.8ms, but doesn't seem to affect fps)

                heading = 230.0,
                home = vector3(-198.797, -1517.553, 31.623),
                guest = vector3(-200.62, -1519.752, 31.623),
                time = vector3(-199.708, -1518.653, 31.623),
                main = vector3(-199.708, -1518.653, 31.623),
            }
        },
        { -- breze mlo
            blip = vector3(-47.91, -1385.55, 29.49),
            start = vector3(-60.55, -1403.22, 29.49),
            ball = vector3(-60.48, -1395.26, 28.5),

            easy_mode = true, -- makes it easier to make a goal

            home = {
                vector3(-48.9, -1395.35, 31.7),
                vector3(-48.9, -1395.35, 31.4)
            },

            guest = {
                vector3(-72.35, -1395.4, 31.7),
                vector3(-72.35, -1395.4, 31.4)
            },

            dunking = {
                home = vector4(-49.63, -1395.39, 31.5, 261.74),
                guest = vector4(-71.43, -1395.23, 31.5, 92.69)
            },

            queue = {
                minimum = 1, -- minimum users per team for a match to start
                timer = 15, -- how long (in seconds) until the match starts, after "minimum" users are in queue per team
                game = 300, -- how long (in seconds) a game lasts
            },

            -- board = {
            --     enabled = true, -- update the score & time on the board? (this impacts performance, ~0.8ms, but doesn't seem to affect fps)

            --     heading = 180.0,
            --     home = vector3(-59.5, -1404.03, 31.95),
            --     guest = vector3(-62.3, -1404.03, 31.95),
            --     time = vector3(-60.95, -1404.03, 32.225),
            --     main = vector3(-60.44, -1395.18, 29.5),
            -- }
        },
    },
}

Strings = {
    ["blip"] = "Basketball",
    ["home"] = "da casa",
    ["guest"] = "visitante",
    ["join_team"] = "Aperte ~INPUT_CONTEXT~ para %s no time \"~b~%s~s~\" (%s no time)\nPress ~INPUT_DETONATE~ para %s no time \"~r~%s~s~\" (%s no time)",
    ["join"] = "entrar",
    ["leave"] = "sair",

    ["game_progress"] = "Há um jogo em andamento.\nEle acaba em: %s %s e %s %s",

    ["waiting"] = "Esperando",
    ["cancelled"] = "O jogo foi cancelado devido a não haver jogadores em uma equipe.",

    ["starting"] = "\nO jogo começa em %s %s e %s %s",
    ["minute"] = "minuto",
    ["minutes"] = "minutos",
    ["second"] = "segundo",
    ["seconds"] = "segundos",

    ["left_queue"] = "Você saiu da fila, após ir para longe.",

    ["steal_ball"] = "Pressione [~b~E~s~] para roubar a bola",
    ["pickup_ball"] = "Pressione [~b~E~s~] para pegar a bola",
    ["ball_info"] = "Pressione ~INPUT_VEH_DUCK~ para largar a bola\nPressione ~INPUT_ATTACK~ para arremessar a bola\nPressione ~INPUT_DETONATE~ para encestar",

    ["goal"] = "Bom arremesso! Você marcou um ponto para o seu time.",
    ["better_luck"] = "Você não pegou a bola",
    ["better_luck_dunk"] = "Você não encestou - Mais sorte da próxima vez",

    ["you_lost"] = "Seu time ~r~perdeu~s~. Mais sorte da próxima vez!",
    ["you_won"] = "Seu time ~g~venceu~s~!",
    ["tie"] = "Seu time ~y~empatou~s~ com a outra equipe.",
}