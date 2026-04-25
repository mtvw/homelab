# Future LXC and VM resources belong here or in dedicated modules once the
# Proxmox baseline is stable.
#
# IP policy:
# - static workload IPs start at 10.0.1.20
# - allocations are recorded centrally in the repo
# - no automatic compaction after deletion unless we intentionally renumber
#
# This avoids accidental IP shifts when an item is removed from the middle of a
# list. "No gaps" and "stable IPs forever" conflict after deletions, so we will
# treat renumbering as an explicit maintenance action.
