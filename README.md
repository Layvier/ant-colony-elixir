# Ant Colony Optimization Algorithm

I built this project in order to learn elixir. It uses different aspect of the language and leverages Erlang's OTP for parallelism. 
I implemented the Ant System version of the ACO meta-heuristic (http://mat.uab.cat/~alseda/MasterOpt/ACO_Intro.pdf).

To start the project, run 

`mix compile && mix run --no-halt`

or

`iex -S mix`

The default instance used is Berlin52.
You can select another instance using the **INSTANCE** environment variable:

`INSTANCE=a280 iex -S mix`