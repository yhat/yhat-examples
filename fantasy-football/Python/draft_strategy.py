import pandas as pd
import numpy as np


###############################################################################
# DATA
df = pd.read_csv("/Users/glamp/Downloads/picks (4).csv")

###############################################################################
# DRAFT STRATEGY

players = df[['player_first', 'player_last', 'player_position', 'player_team', 'playerid']]
players = players[players.duplicated()==False]

training_probs = df.groupby(["playerid", "pk_overall"]).apply(len).reset_index()
training_probs = training_probs.rename(columns={0: "count"})

def freq(grp):
    grp["prob"] = grp["count"] / np.float(np.sum(grp["count"]))
    return grp

training_probs = training_probs.groupby(["pk_overall"]).apply(freq)
training_probs = training_probs.sort(["pk_overall", "prob"], ascending=[1, 0])
###############################################################################

###############################################################################
# LEAGUE FORMAT
# define the parameters for the draft
teams = []
for i in range(10):
    teams.append({
        "QB": [None for i in range(1)],
        "RB": [None for i in range(2)],
        "WR": [None for i in range(2)],
        "TE": [None for i in range(1)],
        "FLEX": [None for i in range(1)],
        "DEF": [None for i in range(1)],
        "PK": [None for i in range(1)],
        "BENCH": [None for i in range(6)]
    })

# setup a snake draft w/ 10 teams
draft_order = []
for i in range(15):
    if i%2==0:
        draft_order += range(0, 10)
    else:
        draft_order += sorted(range(0, 10), reverse=True)


###############################################################################
# DRAFT
def make_pick(team_num, pick_num):
    flex_pos = ["RB","WR"]
    mask = training_probs.pk_overall==pick_num
    pick_sub = training_probs[mask]

    # If there are no consensus picks, pick the next most popular at the previous pic
    # and keep going back picks until there is something.
    while (len(pick_sub) < 1):
        pick_num -= 1
        mask = training_probs.pk_overall==pick_num
        pick_sub = training_probs[mask]

    pick_sub = pick_sub.sort(["count", "prob"], ascending=[0, 0])
    team = teams[team_num]

    selection_made = False
    selection_index = 0

    while (selection_made==False):
        pid = pick_sub[selection_index:selection_index+1]['playerid'].tolist()[0]
        potential_pick = get_playerinfo(pid)
        pick_pos = potential_pick.player_position
        pick_pos = pick_pos.tolist()[0]
        if np.all([x is not None for x in team[pick_pos]])==False:
            selection_made = True
        else:
            if (pick_pos in flex_pos) and (np.all([x is not None for x in team["FLEX"]])==False):
                pick_pos = "FLEX"
                selection_made = True
            else:
                if np.all([x is not None for x in team["BENCH"]])==False:
                    pick_pos = "BENCH"
                    selection_made = True
                else:
                    selection_index += 1

    team = add_player_to_team(team, pick_pos, pid)
    teams[team_num] = team
    draft_sequence.append(pid)
    off_board(pid)
    return pid

def get_playerinfo(pid):
    return players[players.playerid==pid]

def off_board(pid):
    global players, training_probs
    players = players[players.playerid!=pid]
    training_probs = training_probs[training_probs.playerid!=pid]
    return True

def add_player_to_team(team, pos, pid):
    slots = team[pos]
    idx = slots.index(None)
    slots[idx] = pid
    team[pos] = slots
    return team

# keep track of the order of the players drafted
draft_sequence = []

# do the draft!!!
for overall, team in enumerate(draft_order):
    overall += 1
    print "Team %d is on the clock!" % team
    pick = make_pick(team, overall)
    print "With the %d pick, Team %d selects %s: " % (overall, team, pick)
    print "-"*80

###############################################################################
# DEPLOY
from yhat import Yhat, BaseModel

yh = Yhat("drew", "YOUR API KEY")

class FantasyFootball(BaseModel):
    def transform(self, rawdata):
        return rawdata
    
    def predict(self, data):
        return pd.DataFrame({
            "draft_sequence": draft_sequence
            })

ff = FantasyFootball(draft_sequence=draft_sequence)
print yh.deploy("fantasyFootballDraft", ff)
###############################################################################

