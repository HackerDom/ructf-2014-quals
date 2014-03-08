-module(source).
-export([check/1]).

check(List) when is_list(List) ->
    try spwn(List)
    catch _:_ -> ":("
    end.

spwn(List) ->
    spwn(List, [], <<
        69,201,180,89,207,244,28,253,8,176,51,236,104,81,101,111,
        230,62,162,253,22,82,139,243,214,156,27,45,162,121,244,51,
        250,88,135,224,81,9,148,91,206,164,111,170,167,37,204,79,
        165,73,101,96,236,36,13,52,81,178,237,229,135,235,52,191,
        179,178,215,54,135,72,252,227,15,116,64,197,93,231,215,211,
        88,28,58,15,55,211,222,60,247,128,92,49,241,12,248,138,
        220,138,155,208,178,145,100,82,147,239,96,134,147,86,236,35,
        169,178,196,138,90,237,120,183,210,83,221,248,239,55,161,3,
        145,132,42,151,223,155,56,55,248,237,161,39,169,159,22,132,
        188,199,34,24,173,6,83,153,239,118,83,86,204,52,16,35,
        178,117,178,12,223,128,39,72,1,150,203,206,250,177,224,3,
        86,245,34,185,136,161,213,172,198,140,123,67,50,157,110,9,
        174,143,114,238,235,238,126,74,165,86,136,37,202,184,201,251,
        115,177,13,181,83,166,99,64,214,20,133,132,255,35,161,237,
        53,15,18,116,25,65,49,75,24,192,150,195,134,188,62,143,
        58,197,205,71,118,153,166,58,13,155,144,189,200,236,63,28,
        206,207,154,241,194,149,154,118,35,177,42,78,71,210,70,164,
        4,212,252,147,7,182,245,162,140,133,177,140,53,83,191,147,
        92,58,212,95,136,3,42,247,110,125,153,17,194,214,17,217,
        239,168,26,79,115,144,63,199,144,49,187,169,48,131,24,236,
        188,27,71,12,20,243,117,173,235,227,143,245,167,18,111,244,
        182,228,114,12,74,100,115,218,9,130,222,57,43,190,0,94,
        222,118,40,196,47,92,25,80,173,206,52,107,25,13,84,98,
        10,145,236,7,254,178,206,231,102,94,5,119,72,205,158,187,
        129,205,164,155,49,227,86,70,165,35,114,139,167,142,80,199,
        163,40,3,222,131,86,143,88,40,4,226,28,221,32,137,6,
        171,28,170,113,122,237,192,183,253,175,177,238,186,252,184,215,
        114,178,114,71,184,121,160,1,28,60,29,93,201,85,27,223,
        239,254,41,171,22,168,187,185,137,152,73,6,147,117,183,97,
        56,75,235,46,10,39,22,161,172,8,109,175,138,169,113,235,
        160,236,238,106,53,245,138,164,244,222,213,83,64,134,107,210,
        176,221,242,68,176,94,46,227,36,24,120,96,75,48,91,255,
        211,215,219,189,60,25,89,88,166,246,52,52,220,45,66,185,
        79,202,223,159,141,199,201,59,59,142,232,146,236,233,124,216,
        241,157,146,209,120,212,197,38,47,89,126,32,246,87,235,4,
        105,103,140,191,10,5,236,37,58,2,61,148,88,94,118,240,
        20,191,166,187,20,135,94,69,187,160,40,162,30,211,128,70,
        22,121,9,28,90,136,15,175,111,181,230,8,126,177,178,220
    >>).

spwn([], Pids, <<>>) ->
    broadcast({start, Pids}, Pids);
spwn([Head|Tail], Pids, <<Hash:128/bitstring, BitTail/binary>>) ->
    Pid = spawn_link(fun() -> act(Head, Hash) end),
    spwn(Tail, [Pid | Pids], BitTail).

act(X, Hash) ->
    receive
        {start, Pids} -> 
            Me = index_of(self(), Pids),
            calc([X], Me, 0, Hash, Pids)
    after
        5000 ->
            error(":(")
    end.

calc(X, Me, Round, Hash, Pids) ->
    Pos = round(Me + math:pow(2, Round)),
    ShouldSend = Pos =< length(Pids),
    ShouldRecv = round(Me - math:pow(2, Round)) > 0,
    if ShouldSend ->
           Pid = lists:nth(Pos, Pids),
           %erlang:display({send, self(), Pid, X}),
           Pid ! {op, X, Round};
       true -> ok
    end,
    NewX = if ShouldRecv ->
            receive
                {op, Y, Round} ->
                %erlang:display({recv, self(), Y}),
                Y ++ X
            after
                5000 ->
                    error(":(")
            end;
        true ->
            X
    end,
    if not ShouldSend andalso not ShouldRecv ->
            case erlang:md5(NewX) of
                Hash -> ok;
                _    -> error(":(")
            end;
       true ->
            calc(NewX, Me, Round + 1, Hash, Pids)
    end.

broadcast(Msg, [Pid|Pids]) ->
    Pid ! Msg,
    broadcast(Msg, Pids);
broadcast(_, []) ->
    ok.

index_of(Item, List) -> index_of(Item, List, 1).

index_of(_, [], _)  -> false;
index_of(Item, [Item|_], Index) -> Index;
index_of(Item, [_|Tl], Index) -> index_of(Item, Tl, Index+1).
