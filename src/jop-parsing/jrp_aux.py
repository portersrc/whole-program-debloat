#!/usr/bin/env python3


jop_metric_descriptions = {
    'num_uniq_stack_pivot_regs': 'Number of unique stack pivot registers available',
    'num_uniq_stack_pivot_reg_offset_pairs': 'Number of unique stack pivot register-offset pairs',
    'num_uniq_addends_for_add_op': 'Number of unique addends for the add operation (irrespective of the base register)',
    'num_uniq_jump_regs_for_add_op': 'Number of unique JMP registers for the add-op gadgets',
    'num_uniq_gadgets': 'Total number of unique gadgets across all the files',
    'num_uniq_call_gadgets': 'Number of unique call gadgets (irrespective of the base register)',
    'num_len_two_mov_gadgets': 'Number of MOV gadgets with only the mov (length=2)',
    'num_len_two_gadgets': 'Number of gadgets with length=2 (fewer side effects)',
    #'FIXME': 'Breakdown metric for all the gadget depths (depth:number format)',
    'num_uniq_dec_ops': 'Number of unique DEC operations',
    'num_uniq_inc_ops': 'Number of unique INC operations',
    'num_uniq_len_two_push_ops': 'Number of unique, length=2 PUSH operations',
    'num_uniq_sub_ops': 'Number of unique SUB operations',
    'num_uniq_len_two_pop_ops': 'Number of unique, length=2 POP operations',
    'num_lea_ops_for_esp_reg': 'Number of LEA operations for ESP register',
    'num_uniq_lea_ops': 'Number of unique LEA operations',
    'num_best_dispatcher_gadgets': 'Number of "best" dispatcher gadgets',
    'num_dispatcher_gadgets': 'Total number of all dispatcher gadgets that are functional',
    'num_jump_only_mov_ops': 'Number of jump_only MOV operations',
    'num_max_len_three_xchg_ops': 'Number of XCHG operations with length<4',
    'num_uniq_mov_imm_insts': 'Number of unique mov-imm instructions',
    'num_best_two_gadget_dispatchers': 'Number of "best" two-gadget dispatchers (optional)',
    'num_two_gadget_dispatchers': 'Number of all two-gadget dispatchers',
    'num_max_len_three_add_ops': 'Number of unique add operations with length<4',
    'num_rol_ops': 'Number of ROL operations',
    'num_rcr_ops': 'Number of RCR operations',
    'num_uniq_len_two_addends_to_esp': 'Number of unique addends to ESP with length=2 (these can be used as stack pivots so can check JOPs functionality)',
}


jop_metrics = {
    'num_uniq_stack_pivot_regs': 0,
    'num_uniq_stack_pivot_reg_offset_pairs': 0,
    'num_uniq_addends_for_add_op': 0,
    'num_uniq_jump_regs_for_add_op': 0,
    'num_uniq_gadgets': 0,
    'num_uniq_call_gadgets': 0,
    'num_len_two_mov_gadgets': 0,
    'num_len_two_gadgets': 0,
    #'FIXME-breakdown-metric': 0,
    'num_uniq_dec_ops': 0,
    'num_uniq_inc_ops': 0,
    'num_uniq_len_two_push_ops': 0,
    'num_uniq_sub_ops': 0,
    'num_uniq_len_two_pop_ops': 0,
    'num_lea_ops_for_esp_reg': 0,
    'num_uniq_lea_ops': 0,
    'num_best_dispatcher_gadgets': 0,
    'num_dispatcher_gadgets': 0,
    'num_jump_only_mov_ops': 0,
    'num_max_len_three_xchg_ops': 0,
    'num_uniq_mov_imm_insts': 0,
    'num_best_two_gadget_dispatchers': 0,
    'num_two_gadget_dispatchers': 0,
    'num_max_len_three_add_ops': 0,
    'num_rol_ops': 0,
    'num_rcr_ops': 0,
    'num_uniq_len_two_addends_to_esp': 0,
}
















# Gadget files
# These should be exhaustive. Add to this script if missing any.
# Parser will gracefully handle missing files.








gf_add_op = [
    'ADD OP_EAX_1.txt',
    'ADD OP_EBP_1.txt',
    'ADD OP_EBX_1.txt',
    'ADD OP_ECX_1.txt',
    'ADD OP_EDI_1.txt',
    'ADD OP_EDX_1.txt',
    'ADD OP_ESI_1.txt',
    'ADD OP_ESP_1.txt',
]

gf_best_two_gadget_dispatcher = [
    'Best Two-Gadget Dispatcher EAX_1.txt',
    'Best Two-Gadget Dispatcher EBP_1.txt',
    'Best Two-Gadget Dispatcher EBX_1.txt',
    'Best Two-Gadget Dispatcher ECX_1.txt',
    'Best Two-Gadget Dispatcher EDI_1.txt',
    'Best Two-Gadget Dispatcher EDX_1.txt',
    'Best Two-Gadget Dispatcher ESI_1.txt',
]

gf_dec_op = [
    'Dec OP_EAX_1.txt',
    'Dec OP_EBP_1.txt',
    'Dec OP_ECX_1.txt',
    'Dec OP_EDI_1.txt',
    'Dec OP_ESI_1.txt',
    'Dec OP_ESP_1.txt',
]

gf_dispatcher_gadget_best = [
    'Dispatcher Gadget Best EAX_jmp_1.txt',
    'Dispatcher Gadget Best EBX_jmp_1.txt',
    'Dispatcher Gadget Best EDI_jmp_1.txt',
    'Dispatcher Gadget Best ESI_jmp_1.txt',
]

gf_dispatcher_gadget = [
    'Dispatcher Gadget EAX_jmp_1.txt',
    'Dispatcher Gadget EBX_jmp_1.txt',
    'Dispatcher Gadget EDI_jmp_1.txt',
    'Dispatcher Gadget ESI_jmp_1.txt',
]

gf_inc_op = [
    'Inc OP_EAX_1.txt',
    'Inc OP_EBP_1.txt',
    'Inc OP_EBX_1.txt',
    'Inc OP_ECX_1.txt',
    'Inc OP_EDX_1.txt',
    'Inc OP_ESI_1.txt',
]

gf_jmp_ptr = [
    'JMP PTR EBX ALL_1.txt',
    'JMP PTR ECX ALL_1.txt',
    'JMP PTR EDI ALL_1.txt',
    'JMP PTR EDX ALL_1.txt',
    'JMP PTR EMPTY ALL2_1.txt',
    'JMP PTR ESI ALL_1.txt',
    'JMP PTR ESP ALL_1.txt',
    'JMP PTR POP EAX ALL_1.txt',
    'JMP PTR POP EDI ALL_1.txt',
]

gf_lea_op = [
    'Lea OP_EDI_1.txt',
    'Lea OP_ESI_1.txt',
]

gf_mov_deref_op = [
    'Mov Deref OP _EAX_1.txt',
    'Mov Deref OP _EBP_1.txt',
    'Mov Deref OP _EBX_1.txt',
    'Mov Deref OP _ECX_1.txt',
    'Mov Deref OP _EDX_1.txt',
]

gf_mov_op = [
    'Mov OP_EAX_1.txt',
    'Mov OP_EBP_1.txt',
    'Mov OP_EBX_1.txt',
    'Mov OP_ECX_1.txt',
    'Mov OP_EDI_1.txt',
    'Mov OP_EDX_1.txt',
    'Mov OP_ESI_1.txt',
    'Mov OP_ESP_1.txt',
]

gf_movshuf_op = [
    'MovShuf OP_EAX_1.txt',
    'MovShuf OP_EBP_1.txt',
    'MovShuf OP_EBX_1.txt',
    'MovShuf OP_ECX_1.txt',
    'MovShuf OP_EDI_1.txt',
    'MovShuf OP_EDX_1.txt',
    'MovShuf OP_ESI_1.txt',
    'MovShuf OP_ESP_1.txt',
]

gf_movval_op = [
    'MovVal OP_EAX_1.txt',
    'MovVal OP_EBP_1.txt',
    'MovVal OP_EBX_1.txt',
    'MovVal OP_ECX_1.txt',
    'MovVal OP_EDX_1.txt',
    'MovVal OP_ESI_1.txt',
    'MovVal OP_ESP_1.txt',
]

gf_pop_op = [
    'Pop OP_EAX_1.txt',
    'Pop OP_EBP_1.txt',
    'Pop OP_EBX_1.txt',
    'Pop OP_ECX_1.txt',
    'Pop OP_EDI_1.txt',
    'Pop OP_EDX_1.txt',
    'Pop OP_ESI_1.txt',
]

gf_push_op = [
    'Push OP_EAX_1.txt',
    'Push OP_EBP_1.txt',
    'Push OP_EBX_1.txt',
    'Push OP_ECX_1.txt',
    'Push OP_EDI_1.txt',
    'Push OP_EDX_1.txt',
    'Push OP_ESI_1.txt',
    'Push OP_ESP_1.txt',
]

gf_rotate_left_op = [
    'Rotate Left OP_All_1.txt',
]

gf_rotate_right_op = [
    'Rotate Right OP_All_1.txt',
]

gf_shift_left_op = [
    'Shift Left OP_All_1.txt',
]

gf_shift_right_op = [
    'Shift Right OP_All_1.txt',
]

gf_sub_op = [
    'Sub OP_EAX_1.txt',
    'Sub OP_EBX_1.txt',
    'Sub OP_ECX_1.txt',
    'Sub OP_EDX_1.txt',
    'Sub OP_ESI_1.txt',
    'Sub OP_ESP_1.txt',
]

gf_two_gadget_dispatcher = [
    'Two-Gadget Dispatcher EAX_all_1.txt',
    'Two-Gadget Dispatcher EBP_all_1.txt',
    'Two-Gadget Dispatcher EBX_all_1.txt',
    'Two-Gadget Dispatcher ECX_all_1.txt',
    'Two-Gadget Dispatcher EDI_1.txt',
    'Two-Gadget Dispatcher EDX_all_1.txt',
    'Two-Gadget Dispatcher ESI_all_1.txt',
]

gf_xchg_op = [
    'Xchg OP_EAX_1.txt',
    'Xchg OP_EBP_1.txt',
    'Xchg OP_EBX_1.txt',
    'Xchg OP_ECX_1.txt',
    'Xchg OP_EDX_1.txt',
]




def is_add(op):
    if op == 'add' or op == 'adc':
        return True
    return False
def is_jmp(op):
    if op == 'jmp':
        return True
    return False
def is_mov(op):
    if op == 'mov':
        return True
    return False
def is_dec(op):
    if op == 'dec':
        return True
    return False
def is_inc(op):
    if op == 'inc':
        return True
    return False
def is_push(op):
    if op == 'push':
        return True
    return False
def is_sub(op):
    if op == 'sub' or op == 'sbb':
        return True
    return False
def is_pop(op):
    if op == 'pop':
        return True
    return False
def is_lea(op):
    if op == 'lea':
        return True
    return False
def is_rol(op):
    if op == 'rol' or op == 'rcl':
        return True
    return False
def is_rcr(op):
    if op == 'ror' or op == 'rcr':
        return True
    return False



uniq_addends = set()
uniq_jmp_target_regs = set()
uniq_push_regs_len_two_gadget = set()
uniq_sub_ops = set()
uniq_pop_regs_len_two_gadget = set()
uniq_lea_ops = set()
uniq_movval_ops = set()



def parse_gf_add_op(insts):
    reg_to_addend = {}
    for inst in insts:
        inst_parts = inst.split()
        op = inst_parts[0]
        if is_add(op):
            # XXX treating only immediate adds for this metric
            if 'byte ptr' in inst:
                continue
            base_reg = inst_parts[1] # contains the ',' at the end... that's fine
            addend   = inst_parts[2]
            if '0x' in addend:
                addend = int(addend, 16)
            else:
                try:
                    addend = int(addend)
                except:
                    # XXX treating only immediates. ignore this exception (e.g. adding reg to reg)
                    continue
            if base_reg not in reg_to_addend:
                reg_to_addend[base_reg] = 0
            # important to do this += because some add-op gadgets add more than once to same reg
            reg_to_addend[base_reg] += addend
        if is_jmp(op):
            jmp_target_reg = inst_parts[1]
            uniq_jmp_target_regs.add(jmp_target_reg)
    new_addend_found = False
    for base_reg, addend in reg_to_addend.items():
        if addend not in uniq_addends:
            uniq_addends.add(addend)
            new_addend_found = True
            if base_reg == 'esp,' and len(insts) == 2:
                jop_metrics['num_uniq_len_two_addends_to_esp'] += 1
    if new_addend_found and len(insts) < 4:
        # XXX This is imperfectly capturing 'unique add gadgets with length < 4
        # As it stands, the metrics captures an add gadet if there was at least
        # 1 unique addend. But it's also possible to have the same addend in
        # two different gadgets, but where the side effects are slightly
        # different. To improve how I capture this metric in the future, I
        # would need to take the side effects into account.
        jop_metrics['num_max_len_three_add_ops'] += 1


def parse_gf_best_two_gadget_dispatcher(insts):
    jop_metrics['num_best_two_gadget_dispatchers'] += 1
    

def parse_gf_dec_op(insts):
    for inst in insts:
        inst_parts = inst.split()
        op = inst_parts[0]
        if is_dec(op):
            jop_metrics['num_uniq_dec_ops'] += 1


def parse_gf_dispatcher_gadget_best(insts):
    jop_metrics['num_best_dispatcher_gadgets'] += 1


def parse_gf_dispatcher_gadget(insts):
    # TODO? What is meant by dispatcher gadgets "that are functional"?
    jop_metrics['num_dispatcher_gadgets'] += 1


def parse_gf_inc_op(insts):
    for inst in insts:
        inst_parts = inst.split()
        op = inst_parts[0]
        if is_inc(op):
            jop_metrics['num_uniq_inc_ops'] += 1

def parse_gf_jmp_ptr(insts):
    pass
def parse_gf_lea_op(insts):
    for inst in insts:
        inst_parts = inst.split()
        op = inst_parts[0]
        if is_lea(op):
            # capture the the full instruction (up to the tab before the hex instruction address)
            inst_parts_tab = inst.split('\t')
            uniq_lea_ops.add(inst_parts_tab[0])

def parse_generic_mov(insts):
    if len(insts) == 2:
        inst_parts = insts[0].split()
        op = inst_parts[0]
        if is_mov(op):
            jop_metrics['num_len_two_mov_gadgets'] += 1
def parse_gf_mov_deref_op(insts):
    parse_generic_mov(insts)
def parse_gf_mov_op(insts):
    parse_generic_mov(insts)
def parse_gf_movshuf_op(insts):
    parse_generic_mov(insts)
def parse_gf_movval_op(insts):
    parse_generic_mov(insts)
    for inst in insts:
        inst_parts = inst.split()
        op = inst_parts[0]
        if is_mov(op):
            # capture the the full instruction (up to the tab before the hex instruction address)
            inst_parts_tab = inst.split('\t')
            uniq_movval_ops.add(inst_parts_tab[0])


def parse_gf_pop_op(insts):
    if len(insts) == 2:
        inst_parts = insts[0].split()
        op = inst_parts[0]
        if is_pop(op):
            pop_reg = inst_parts[1]
            uniq_pop_regs_len_two_gadget.add(pop_reg)

# TODO
# If the length is > 2, but the instruction before the jmp is a push,
# then it's fine to count it. It implies there was at least one more push above
# it, but it could be clipped to be considered as a length 2 gadget. This applies
# to length-2 pop gadgets and maybe one or two other metrics
def parse_gf_push_op(insts):
    if len(insts) == 2:
        inst_parts = insts[0].split()
        op = inst_parts[0]
        if is_push(op):
            push_reg = inst_parts[1]
            uniq_push_regs_len_two_gadget.add(push_reg)


def parse_gf_rotate_left_op(insts):
    for inst in insts:
        inst_parts = inst.split()
        op = inst_parts[0]
        if is_rol(op):
            jop_metrics['num_rol_ops'] += 1


def parse_gf_rotate_right_op(insts):
    for inst in insts:
        inst_parts = inst.split()
        op = inst_parts[0]
        if is_rcr(op):
            jop_metrics['num_rcr_ops'] += 1


def parse_gf_shift_left_op(insts):
    pass
def parse_gf_shift_right_op(insts):
    pass


def parse_gf_sub_op(insts):
    for inst in insts:
        inst_parts = inst.split()
        op = inst_parts[0]
        if is_sub(op):
            # capture the the full instruction (up to the tab before the hex instruction address)
            inst_parts_tab = inst.split('\t')
            uniq_sub_ops.add(inst_parts_tab[0])


def parse_gf_two_gadget_dispatcher(insts):
    jop_metrics['num_two_gadget_dispatchers'] += 1


def parse_gf_xchg_op(insts):
    if len(insts) < 4:
        jop_metrics['num_max_len_three_xchg_ops'] += 1



def finalize_metrics():
    jop_metrics['num_uniq_addends_for_add_op'] = len(uniq_addends)
    jop_metrics['num_uniq_jump_regs_for_add_op'] = len(uniq_jmp_target_regs)
    jop_metrics['num_uniq_len_two_push_ops'] = len(uniq_push_regs_len_two_gadget)
    jop_metrics['num_uniq_sub_ops'] = len(uniq_sub_ops)
    jop_metrics['num_uniq_len_two_pop_ops'] = len(uniq_pop_regs_len_two_gadget)
    jop_metrics['num_uniq_lea_ops'] = len(uniq_lea_ops)
    jop_metrics['num_uniq_mov_imm_insts'] = len(uniq_movval_ops)



gadget_types = [
    'gt_add_op',
    'gt_best_two_gadget_dispatcher',
    'gt_dec_op',
    'gt_dispatcher_gadget_best',
    'gt_dispatcher_gadget',
    'gt_inc_op',
    'gt_jmp_ptr',
    'gt_lea_op',
    'gt_mov_deref_op',
    'gt_mov_op',
    'gt_movshuf_op',
    'gt_movval_op',
    'gt_pop_op',
    'gt_push_op',
    'gt_rotate_left_op',
    'gt_rotate_right_op',
    'gt_shift_left_op',
    'gt_shift_right_op',
    'gt_sub_op',
    'gt_two_gadget_dispatcher',
    'gt_xchg_op',
]
gt_to_gf_arr = {
    'gt_add_op': gf_add_op,
    'gt_best_two_gadget_dispatcher': gf_best_two_gadget_dispatcher,
    'gt_dec_op': gf_dec_op,
    'gt_dispatcher_gadget_best': gf_dispatcher_gadget_best,
    'gt_dispatcher_gadget': gf_dispatcher_gadget,
    'gt_inc_op': gf_inc_op,
    'gt_jmp_ptr': gf_jmp_ptr,
    'gt_lea_op': gf_lea_op,
    'gt_mov_deref_op': gf_mov_deref_op,
    'gt_mov_op': gf_mov_op,
    'gt_movshuf_op': gf_movshuf_op,
    'gt_movval_op': gf_movval_op,
    'gt_pop_op': gf_pop_op,
    'gt_push_op': gf_push_op,
    'gt_rotate_left_op': gf_rotate_left_op,
    'gt_rotate_right_op': gf_rotate_right_op,
    'gt_shift_left_op': gf_shift_left_op,
    'gt_shift_right_op': gf_shift_right_op,
    'gt_sub_op': gf_sub_op,
    'gt_two_gadget_dispatcher': gf_two_gadget_dispatcher,
    'gt_xchg_op': gf_xchg_op,
}
gt_to_parser = {
    'gt_add_op': parse_gf_add_op,
    'gt_best_two_gadget_dispatcher': parse_gf_best_two_gadget_dispatcher,
    'gt_dec_op': parse_gf_dec_op,
    'gt_dispatcher_gadget_best': parse_gf_dispatcher_gadget_best,
    'gt_dispatcher_gadget': parse_gf_dispatcher_gadget,
    'gt_inc_op': parse_gf_inc_op,
    'gt_jmp_ptr': parse_gf_jmp_ptr,
    'gt_lea_op': parse_gf_lea_op,
    'gt_mov_deref_op': parse_gf_mov_deref_op,
    'gt_mov_op': parse_gf_mov_op,
    'gt_movshuf_op': parse_gf_movshuf_op,
    'gt_movval_op': parse_gf_movval_op,
    'gt_pop_op': parse_gf_pop_op,
    'gt_push_op': parse_gf_push_op,
    'gt_rotate_left_op': parse_gf_rotate_left_op,
    'gt_rotate_right_op': parse_gf_rotate_right_op,
    'gt_shift_left_op': parse_gf_shift_left_op,
    'gt_shift_right_op': parse_gf_shift_right_op,
    'gt_sub_op': parse_gf_sub_op,
    'gt_two_gadget_dispatcher': parse_gf_two_gadget_dispatcher,
    'gt_xchg_op': parse_gf_xchg_op,
}