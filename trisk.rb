#!/usr/bin/ruby -w

require 'csv'

runfile=ARGV[0]
baseline=ARGV[1]
metric=ARGV[2] # e.g "ndcg@10"
mode=(ARGV[3].to_i) # 1 = inferrential mode, 2 = exploratory mode
mode = (mode == 0) ? 1 : mode

$alpha=0.0

$run_map = Hash.new
$baseline_map = Hash.new
$risk_reward = []
$urisk = 0.0
$c = 0

def risk_reward_tradeoff_score(topic)
    r = $run_map[topic]
    b = $baseline_map[topic]

    return (r - b) if r > b
    return (1 + $alpha) * (r - b) if r < b
    return 0.000
end

def sx
    sum = 0.0
    $risk_reward.each { |x| sum += ((x - $urisk) ** 2) }
    sum /= $c
    return Math.sqrt(sum)
end

def parametric_standard_error_estimation
    return (1 / Math.sqrt($c)) * sx 
end

# Load in the CSV files into their respective maps.

CSV.foreach(runfile, :headers => true) do |row|
    next if row['topic'] == 'amean'
    $run_map[row['topic']] = row[metric].to_f
end

$c = $run_map.keys.size

CSV.foreach(baseline, :headers => true) do |row|
    next if row['topic'] == 'amean'
    $baseline_map[row['topic']] = row[metric].to_f
end
$bc = $baseline_map.keys.size
puts "Warning: c and bc do not match" if $c != $bc

if mode == 1
    # Build the set of risk reward scores
    puts "alpha,urisk,trisk,pvalue"
    [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0].each do |alpha|
        $risk_reward = []

        $alpha = alpha
        $run_map.each do |topic, aggregate|
            val = risk_reward_tradeoff_score(topic)
            $risk_reward << val
        end

        # Calculate the mean of the risk reward scores. This is the URisk score.
        $urisk = $risk_reward.inject{ |sum, el| sum + el }.to_f / $risk_reward.size

        $se = parametric_standard_error_estimation
        $trisk = $urisk / $se

        # R's distribution function from the TDist package is used to convert
        # t-values into p-values. The degrees of freedom is given by the 
        # number of topics - 1.
        df = $run_map.keys.count - 1
        $pvalue = `Rscript --vanilla calc_pvalue.R #{$trisk.round(4)} #{df}`.split(' ')[1].to_f
        puts "#{alpha.round(1)},#{$urisk.round(4)},#{$trisk.round(4)},#{$pvalue.round(4)}" 
    end
else
    puts "alpha,topic,trisk,pvalue"
    [0.0, 1.0, 5.0].each do |alpha|
        $risk_reward = []

        $alpha = alpha
        $run_map.each do |topic, aggregate|
            val = risk_reward_tradeoff_score(topic)
            $risk_reward << val
        end

        # Calculate the mean of the risk reward scores. This is the URisk score.
        $urisk = $risk_reward.inject{ |sum, el| sum + el }.to_f / $risk_reward.size

        sx_val = sx
        df = $run_map.keys.count - 1
        $run_map.each do |topic, aggregate|
            tri = risk_reward_tradeoff_score(topic) / sx_val
            pvalue = `Rscript --vanilla calc_pvalue.R #{tri.round(4)} #{df}`.split(' ')[1].to_f
            puts "#{alpha.round(1)},#{topic},#{tri.round(3)},#{pvalue.round(4)}" 
        end
    end
end
